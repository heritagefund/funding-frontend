require 'restforce'

class PreApplicationToSalesforceJob < ApplicationJob
  class SalesforceApexError < StandardError; end
  queue_as :default

  # Method responsible for orchestrating the submission of a pre-application payload
  # to Salesforce, updating relevant attributes upon completion, and queuing of
  # confirmation emails
  # @param [PreApplication] pre_application
  def perform(pre_application)

    logger.info("Submitting pre_application ID: #{pre_application.id} to Salesforce")

    pre_application.update(submitted_on: DateTime.now)

    client = create_restforce_client()

    json = pre_application.to_salesforce_json()

    response = submit_to_salesforce(client, json)

    response_body_obj = JSON.parse(response&.body)

    if (response_body_obj&.dig('status') == 'Success')

      update_pre_application(pre_application, json, response_body_obj)

      update_organisation(
        pre_application.user.organisations.first,
        response_body_obj
      )

      queue_submission_confirmation_email(pre_application)

      logger.info("Successfully handled submission of pre_application ID: #{pre_application.id} to Salesforce")

    else

      raise SalesforceApexError.new(
        "Failure response from Salesforce when POSTing pre_application ID: #{pre_application.id}, status code: #{response&.status}"
      )

    end

  end

  private

  # Method responsible for creating a RESTforce client
  def create_restforce_client

    logger.info('Creating RESTforce client...')

    client = Restforce.new(
      username: Rails.configuration.x.salesforce.username,
      password: Rails.configuration.x.salesforce.password,
      security_token: Rails.configuration.x.salesforce.security_token,
      client_id: Rails.configuration.x.salesforce.client_id,
      client_secret: Rails.configuration.x.salesforce.client_secret,
      host: Rails.configuration.x.salesforce.host,
      api_version: '47.0'
    )

    logger.info('Completed creation of RESTforce client')

  end

  # Method responsible for submitting a pre-application payload to Salesforce
  #
  # @param [Restforce] client An instance of a RESTforce client
  # @param [JSON] payload The JSON payload to submit to Salesforce
  def submit_to_salesforce(client, payload)

    logger.info('Submitting pre-application payload to Salesforce...')

    response = client.post(
      '/services/apexrest/pre-application',
      payload,
      { 'Content-Type' => 'application/json' }
    )

    logger.info('Completed submission of pre-application payload to Salesforce')

  end

  # Method responsible for updating relevant pre-application attributes post-submission
  #
  # @param [PreApplication] pre_application An instance of a PreApplication object
  # @param [JSON] submitted_payload The JSON payload that was submitted to Salesforce
  # @param [JSON] response A JSON response from Salesforce
  def update_pre_application(pre_application, submitted_payload, response)

    logger.info('Updating pre-application object post payload submission...')

    pre_application.update(
      submitted_payload: submitted_payload,
      salesforce_case_number: response.dig('caseNumber'),
      salesforce_case_id: response.dig('caseId')
    )

    logger.info('Completed update of pre-application object')

  end

  # Method responsible for updating relevant organisation attributes post-submission
  #
  # @param [Organisation] organisation An instance of an Organisation object
  # @param [JSON] response A JSON response from Salesforce
  def update_organisation(organisation, response)

    logger.info('Updating organisation object post payload submission...')

    organisation.update(
      salesforce_account_id: response.dig('accountId')
    )

    logger.info('Completed update of organisation object')

  end

  # Method responsible for queuing the relevant NotifyMailer submission confirmation email
  #
  # @param [PreApplication] pre_application An instance of a PreApplication object
  def queue_submission_confirmation_email(pre_application)

    logger.info('Queuing pre-application submission confirmation email...')

    NotifyMailer.project_enquiry_submission_confirmation(pre_application).deliver_later() if 
      pre_application.pa_project_enquiry.present?

    NotifyMailer.expression_of_interest_submission_confirmation(pre_application).deliver_later() if
      pre_application.pa_expression_of_interest.present?

    logger.info('Completed queuing of pre-application submission confirmation email')

  end

end
