require 'restforce'

class ApplicationToSalesforceJob < ApplicationJob
  class SalesforceApexError < StandardError; end
  queue_as :default

  # @param [Project] project
  def perform(project)

    logger.info("Submitting Project ID: #{project.id} to Salesforce")

    @json = project.to_salesforce_json

    project.funding_application.update(
      submitted_on: DateTime.now,
      submitted_payload: JSON.parse(@json)
    )

    client = Restforce.new(
        username: Rails.configuration.x.salesforce.username,
        password: Rails.configuration.x.salesforce.password,
        security_token: Rails.configuration.x.salesforce.security_token,
        client_id: Rails.configuration.x.salesforce.client_id,
        client_secret: Rails.configuration.x.salesforce.client_secret,
        host: Rails.configuration.x.salesforce.host,
        api_version: '47.0'
    )

    @response = client.post(
      '/services/apexrest/PortalData',
      @json,
      { 'Content-Type' => 'application/json' }
    )

    @response_body_obj = JSON.parse(@response&.body)

    is_successful = @response_body_obj&.dig('status') == 'Success'

    if(is_successful)

      project.funding_application.update(
        salesforce_case_number: @response_body_obj.dig('caseNumber'),
        salesforce_case_id: @response_body_obj.dig('caseId'),
        project_reference_number: @response_body_obj.dig('projectRefNumber')
      )

      project.user.organisations.first.update(
        salesforce_account_id: @response_body_obj.dig('accountId')
      )

      NotifyMailer.project_submission_confirmation(project).deliver_later

      salesforce_case_id = project.funding_application.salesforce_case_id

      ApplicationAttachmentsToSalesforceJob.perform_later(
        salesforce_case_id,
        project,
        :capital_work_file,
        "capital work attachment"
      ) if project.capital_work_file.attached?

      ApplicationAttachmentsToSalesforceJob.perform_later(
        salesforce_case_id,
        project,
        :governing_document_file,
        "governing document attachment"
      ) if project.governing_document_file.attached?

      project.accounts_files.each_with_index do |af, idx|
        ApplicationAttachmentsToSalesforceJob.perform_later(
          salesforce_case_id,
          project,
          :accounts_files,
          "accounts attachment ##{idx}",
          idx)
      end

      project.evidence_of_support.each do |eos|
        ApplicationAttachmentsToSalesforceJob.perform_later(
          salesforce_case_id,
          eos,
          :evidence_of_support_files,
          eos.description
        )
      end

      project.cash_contributions.filter{ |cc| cc.cash_contribution_evidence_files.attached? }.each do |cc|
        ApplicationAttachmentsToSalesforceJob.perform_later(
          salesforce_case_id,
          cc,
          :cash_contribution_evidence_files,
          cc.description
        )
      end

    else

      raise SalesforceApexError.new("Failure response from Salesforce when POSTing project ID: #{project.id}, status code: #{@response&.status}")

    end

  end

end
