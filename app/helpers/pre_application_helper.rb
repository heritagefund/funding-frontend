module PreApplicationHelper
  include SalesforceApi
  
  # Method to determine which redirect path to take based on whether the
  # Organsiation object passed into the method is complete for this journey
  # type.
  #
  # If the organisation object does not have mandatory attributes
  # populated, then the user is redirected to :pre_application_organisation_type.
  # 
  # Otherwise, the user is redirected to
  # :pre_application_project_enquiry_previous_contact_path
  #
  # @param [Organisation] organisation An instance of an Organisation
  def redirect_based_on_organisation_completeness(organisation, pre_application_type)

    if complete_organisation_details_for_pre_application?(organisation)

      logger.info("Organisation details complete for #{organisation.id}")

      redirect_to(
        pre_application_project_enquiry_previous_contact_path(
          @pre_application.id
        )
      ) if pre_application_type == 'pa_project_enquiry'

      redirect_to(
        pre_application_expression_of_interest_previous_contact_path(
          @pre_application.id
        )
      ) if pre_application_type == 'pa_expression_of_interest'

    else

      logger.info("Organisation details incomplete for #{organisation.id}")

      redirect_to(
        pre_application_organisation_type_path(
          @pre_application.id,
          organisation.id
        )
      )

    end

  end

  # Method to orchestrate sending a pre-application to Salesforce
  # Determines whether the pre-application is an project enquiry or expression of interest,
  # then takes specific actions for them
  # After each Salesforce record is completed, the Salesforce reference is written back to
  # the associated PaProjectEnquiry, PaExpressionOfInterest, Organisation or User instance.
  #
  # @param [PreApplication] pre_application An instance of PreApplication
  # @param [User] user An instance of User
  # @param [Organisation] organisation An instance of Organisation
  def send_pre_application_to_salesforce(pre_application, user, organisation)

    salesforce_api_client = SalesforceApiClient.new
 
    if pre_application.pa_project_enquiry.present?

      salesforce_references = salesforce_api_client.create_project_enquiry(
        pre_application.pa_project_enquiry,
        user,
        organisation
      )

      pre_application.pa_project_enquiry.update(
        salesforce_project_enquiry_id: salesforce_references[:salesforce_project_enquiry_reference]
      ) if pre_application.pa_project_enquiry.salesforce_project_enquiry_id.nil?

    end

    if pre_application.pa_expression_of_interest.present?

      salesforce_references = salesforce_api_client.create_expression_of_interest(
        pre_application.pa_expression_of_interest,
        user,
        organisation
      )

      pre_application.pa_expression_of_interest.update(
        salesforce_expression_of_interest_id: salesforce_references[:salesforce_expression_of_interest_id],
        salesforce_eoi_reference: salesforce_references[:salesforce_expression_of_interest_reference],
      ) if pre_application.pa_expression_of_interest.salesforce_expression_of_interest_id.nil?

    end

    queue_submission_confirmation_email(pre_application)

    pre_application.update(
      submitted_on: DateTime.now
    )

    user.update(
      salesforce_contact_id: salesforce_references[:salesforce_contact_reference]
    ) if user.salesforce_contact_id.nil?

    organisation.update(
      salesforce_account_id: salesforce_references[:salesforce_organisation_reference]
    ) if organisation.salesforce_account_id.nil?
    
  end

  # Method to forward user preferences to Salesforce
  #
  # @param [PreApplication] pre_application An instance of PreApplication
  # @param [User] user An instance of User
  def send_pre_application_user_preferences_to_salesforce(pre_application, user)

    salesforce_api_client = SalesforceApiClient.new

    salesforce_api_client.update_project_enquiry_can_contact_applicant(
      pre_application.pa_project_enquiry,
      user
    ) if pre_application.pa_project_enquiry.present?

    salesforce_api_client.update_expression_of_interest_can_contact_applicant(
      pre_application.pa_expression_of_interest,
      user
    ) if pre_application.pa_expression_of_interest.present?

    salesforce_api_client.update_agrees_to_user_research(user) 

  end

  private

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
