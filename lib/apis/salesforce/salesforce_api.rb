module SalesforceApi

  # Class to allow interaction with Salesforce via a Restforce client
  class SalesforceApiClient

    MAX_RETRIES = 3

    # Overrides the .new() method, allowing us to initialise a Restforce client
    # when the SalesforceApiClient class is instantiated
    def initialize

      initialise_client

    end

    # Method to retrieve details needed during a payment request journey
    #
    # @example
    #
    #   instantiated_object.get_payment_related_details('6665bd00-db85-4f68-95e3-16f9ca99ba40')
    #
    # @param [String] id A project's UUID
    #
    # @return [Hash] A Hash, currently containing only the amount awarded to the project
    #                and the percentage of the total costs that the organisation have agreed
    #                to award
    def get_payment_related_details(id)

      Rails.logger.info("Retrieving payment-related details for project ID: #{id}")

      retry_number = 0

      begin

        # Equivalent of "SELECT Grant_Award__c, Grant_Percentage__c FROM Case WHERE ApplicationId__c = '#{id}'"
        restforce_response = @client.select('Case', id, ['Grant_Award__c', 'Grant_Percentage__c'], 'ApplicationId__c')

      rescue Restforce::NotFoundError => e

        Rails.logger.error(
          "Exception occured when retrieving payment-related details for project ID: #{id}:" \
          " - no Case found for #{id} (#{e})"
        )

        # Raise and allow global exception handler to catch
        raise

      rescue Restforce::MatchesMultipleError, Restforce::UnauthorizedError,
             Restforce::EntityTooLargeError, Restforce::ResponseError => e

        Rails.logger.error(
          "Exception occured when retrieving payment-related details for project ID: #{id}: (#{e})"
        )

        # Raise and allow global exception handler to catch
        raise

      rescue Timeout::Error, Faraday::ClientError => e

        if retry_number < MAX_RETRIES

          retry_number += 1

          max_sleep_seconds = Float(2 ** retry_number)

          Rails.logger.info(
            "Will attempt get_payment_related_details again, retry number #{retry_number} " \
            "after a sleeping for up to #{max_sleep_seconds} seconds"
          )

          sleep rand(0..max_sleep_seconds)

          retry

        else

          raise

        end

      end

      Rails.logger.info("Finished retrieving payment-related details for project ID: #{id}")

      {
        'grant_award': restforce_response.Grant_Award__c,
        'grant_percentage': restforce_response.Grant_Percentage__c
      }

    end

    def get_agreed_project_costs(id)

      Rails.logger.info("Retrieving agreed project costs for project ID: #{id}")

      retry_number = 0

      # TODO: remove 
      id = '37da105a-a899-4868-9a26-7a1329b5ef0a'

      begin

        # Equivalent of "SELECT SUM(Costs__c), Cost_heading__c FROM Project_Cost__c
        # WHERE Case__r.ApplicationId__c= '#{id}' GROUP BY Cost_heading__c"
        restforce_response = @client.query(
          "SELECT SUM(Costs__c), Cost_heading__c FROM Project_Cost__c WHERE Case__r.ApplicationId__c= '#{id}' GROUP BY Cost_heading__c"
        )

        if restforce_response.length == 0

          error_msg = "No project costs found when retrieving agreed project costs for project ID: #{id}"

          Rails.logger.error(error_msg)

          raise Restforce::NotFoundError.new(error_msg, { status: 500 } )

        end

        restforce_response

      rescue Restforce::MatchesMultipleError, Restforce::UnauthorizedError,
             Restforce::EntityTooLargeError, Restforce::ResponseError => e

        Rails.logger.error(
          "Exception occured when retrieving agreed project costs for project ID: #{id}: (#{e})"
        )

        # Raise and allow global exception handler to catch
        raise

      rescue Timeout::Error, Faraday::ClientError => e

        if retry_number < MAX_RETRIES

          retry_number += 1

          max_sleep_seconds = Float(2 ** retry_number)

          Rails.logger.info(
            "Will attempt get_agreed_project_costs again, retry number #{retry_number} " \
            "after a sleeping for up to #{max_sleep_seconds} seconds"
          )

          sleep rand(0..max_sleep_seconds)

          retry

        else

          raise

        end

      end

    end

    # Method to upsert salesforce objects needed for an expression of interest
    #
    # @param [PaExpressionOfInterest] an expression of interest captured so far
    # @param [User] instance of current User
    # @param [Organisation] instance of current User's organisation
    #
    # @return [Hash] A Hash, currently containing the salesforce references to the PEF, Contact and Organisation Salesforce objects
    def create_expression_of_interest(expression_of_interest, user, organisation)

      retry_number = 0

      begin

        salesforce_organisation_reference = create_organisation_in_salesforce(organisation)

        salesforce_contact_reference = upsert_contact_in_salesforce(user, salesforce_organisation_reference)

        salesforce_expression_of_interest_id = @client.upsert!(
          'Expression_Of_Interest__c',
          'Expression_Of_Interest_external_ID__c',
          Expression_Of_Interest_external_ID__c: expression_of_interest.id,
          Heritage_Focus__c: expression_of_interest.heritage_focus,
          Can_Contact_Applicant__c: false, 
          Potential_Funding_Amount__c: expression_of_interest.potential_funding_amount,
          Previous_Fund_Contact__c: expression_of_interest.previous_contact_name,
          What_Project_Does__c: expression_of_interest.what_project_does,
          Programme_Outcomes__c: expression_of_interest.programme_outcomes,
          Project_Reasons__c: expression_of_interest.project_reasons,
          Timescales__c: expression_of_interest.project_timescales, 
          Project_Title__c: expression_of_interest.working_title,
          Overall_cost__c: expression_of_interest.overall_cost,
          Likely_Submission_Description__c: expression_of_interest.likely_submission_description,
          Contact__c: salesforce_contact_reference,
          Name_of_your_organisation__c: salesforce_organisation_reference
        )

        Rails.logger.info(
          'Created an expression of interest record in Salesforce with ' \
          "reference: #{salesforce_expression_of_interest_id}"
        )

        {
          salesforce_organisation_reference: salesforce_organisation_reference,
          salesforce_contact_reference: salesforce_contact_reference,
          salesforce_expression_of_interest_id: salesforce_expression_of_interest_id,
          salesforce_expression_of_interest_reference: get_salesforce_expression_of_interest_reference(expression_of_interest)
        }

      rescue Restforce::MatchesMultipleError, Restforce::UnauthorizedError,
             Restforce::EntityTooLargeError, Restforce::ResponseError => e

        Rails.logger.error(
          'Error creating an expression of interest record in Salesforce using pa_expression_of_interest ' \
          "#{expression_of_interest.id}, user #{user.id} and organisation #{organisation.id}"
        )

        # Raise and allow global exception handler to catch
        raise

      rescue Timeout::Error, Faraday::ClientError => e

        if retry_number < MAX_RETRIES

          retry_number += 1

          max_sleep_seconds = Float(2 ** retry_number)

          Rails.logger.info(
            "Will attempt create_expression_of_interest again, retry number #{retry_number} " \
            "after a sleeping for up to #{max_sleep_seconds} seconds"
          )

          sleep rand(0..max_sleep_seconds)

          retry

        else

          raise

        end

      end

    end

    # Method to upsert salesforce objects needed for a project enquiry
    # Restforce documentation: https://github.com/restforce/restforce#upsert indicates no account
    # reference returned from Salesforce API upon upsert - but it is now.
    #
    # @param [PaProjectEnquiry] project_enquiry An instance of PaProjectEnquiry
    # @param [User] user An instance of User
    # @param [Organisation] organisation An instance of Organisation
    #
    # @return [Hash] A Hash, currently containing the salesforce references to the PEF,
    #                Contact and Organisation Salesforce objects
    def create_project_enquiry(project_enquiry, user, organisation)
      
      Rails.logger.info(
        "Begin creating organisation, contact and project enquiry objects in Salesforce"
      )

      retry_number = 0

      begin
        
        salesforce_organisation_reference = create_organisation_in_salesforce(organisation)

        salesforce_contact_reference = upsert_contact_in_salesforce(user, salesforce_organisation_reference)

        salesforce_project_enquiry_reference = @client.upsert!(
          'Project_Enquiry__c',
          'Project_Enquiry_external_ID__c',
          Project_Enquiry_external_ID__c: project_enquiry.id,
          Heritage_Focus__c: project_enquiry.heritage_focus,
          Likely_cost__c: project_enquiry.project_likely_cost,
          Can_Contact_Applicant__c: false, 
          Potential_Funding_Amount__c: project_enquiry.potential_funding_amount,
          Previous_Fund_Contact__c: project_enquiry.previous_contact_name,
          What_Project_Does__c: project_enquiry.what_project_does,
          Programme_Outcomes__c: project_enquiry.programme_outcomes,
          Project_Reasons__c: project_enquiry.project_reasons,
          Project_Participants__c: project_enquiry.project_participants,
          Timescales__c: project_enquiry.project_timescales, 
          Project_Title__c: project_enquiry.working_title,
          Contact__c: salesforce_contact_reference,
          Name_of_your_organisation__c: salesforce_organisation_reference
        )
 
        Rails.logger.info(
          "Created a project enquiry record in Salesforce with reference: #{salesforce_project_enquiry_reference}"
        )

        {
          salesforce_organisation_reference: salesforce_organisation_reference,
          salesforce_contact_reference: salesforce_contact_reference,
          salesforce_project_enquiry_reference: salesforce_project_enquiry_reference
        }

      rescue Restforce::MatchesMultipleError, Restforce::UnauthorizedError,
             Restforce::EntityTooLargeError, Restforce::ResponseError => e

        Rails.logger.error(
          "Error creating a project enquiry record in Salesforce using pa_project_enquiry #{project_enquiry.id}," \
          " user #{user.id} and organisation #{organisation.id}"
        )

        # Raise and allow global exception handler to catch
        raise

      rescue Timeout::Error, Faraday::ClientError => e

        if retry_number < MAX_RETRIES

          retry_number += 1

          max_sleep_seconds = Float(2 ** retry_number)

          Rails.logger.info(
            "Will attempt create_project_enquiry again, retry number #{retry_number} " \
            "after a sleeping for up to #{max_sleep_seconds} seconds"
          )

          sleep rand(0..max_sleep_seconds)

          retry

        else

          raise

        end  

      end

    end

    # Method to update the can_contact_applicant part of a project enquiry on Salesforce
    #
    # @param [PaProjectEnquiry] project_enquiry An instance of PaProjectEnquiry
    # @param [User] user An instance of User
    def update_project_enquiry_can_contact_applicant(project_enquiry, user)
      
      retry_number = 0

      begin

        @client.update!(
          'Project_Enquiry__c',
          Id: project_enquiry.salesforce_project_enquiry_id,
          Can_Contact_Applicant__c: (user.agrees_to_contact.present?) ? user.agrees_to_contact : false
        )

      rescue Restforce::MatchesMultipleError, Restforce::UnauthorizedError,
             Restforce::EntityTooLargeError, Restforce::ResponseError => e

        Rails.logger.error("Error updating Can Contact Applicant for user #{user.id}")

        # Raise and allow global exception handler to catch
        raise

      rescue Timeout::Error, Faraday::ClientError => e

        if retry_number < MAX_RETRIES

          retry_number += 1

          max_sleep_seconds = Float(2 ** retry_number)

          Rails.logger.info(
            "Will attempt update_project_enquiry_can_contact_applicant again, retry number #{retry_number} " \
            "after a sleeping for up to #{max_sleep_seconds} seconds"
          )

          sleep rand(0..max_sleep_seconds)

          retry

        else

          raise

        end

      end

    end

    # Method to update the can_contact_applicant part of an expression of interest on Salesforce
    #
    # @param [PaExpressionOfInterest] expression_of_interest An instance of PaExpressionOfInterest
    # @param [User] user An instance of User
    def update_expression_of_interest_can_contact_applicant(expression_of_interest, user)

      retry_number = 0

      begin

        salesforce_expression_of_interest = @client.find(
          'Expression_Of_Interest__c',
          expression_of_interest.id,
          'Expression_Of_Interest_external_ID__c'
        )

        @client.update!(
          'Expression_Of_Interest__c',
          Id: salesforce_expression_of_interest[:Id],
          Can_Contact_Applicant__c: (user.agrees_to_contact.present?) ? user.agrees_to_contact : false
        )

      rescue Restforce::MatchesMultipleError, Restforce::UnauthorizedError,
             Restforce::EntityTooLargeError, Restforce::ResponseError => e

        Rails.logger.error("Error updating Can Contact Applicant for user #{user.id}")

        # Raise and allow global exception handler to catch
        raise

      rescue Timeout::Error, Faraday::ClientError => e

        if retry_number < MAX_RETRIES

          retry_number += 1

          max_sleep_seconds = Float(2 ** retry_number)

          Rails.logger.info(
            "Will attempt update_expression_of_interest_can_contact_applicant again, retry number #{retry_number} " \
            "after a sleeping for up to #{max_sleep_seconds} seconds"
          )

          sleep rand(0..max_sleep_seconds)

          retry

        else

          raise

        end

      end

    end

    # Method to update the agrees to user research part of a Contact on Salesforce
    #
    # @param [User] user An instance of a User
    def update_agrees_to_user_research(user)

      retry_number = 0

      begin
        
        @client.update!(
          'Contact',
          Id: user.salesforce_contact_id,
          Agrees_To_User_Research__c: (user.agrees_to_user_research.present?) ? user.agrees_to_user_research : false
        )

      rescue Restforce::MatchesMultipleError, Restforce::UnauthorizedError,
             Restforce::EntityTooLargeError, Restforce::ResponseError => e

        Rails.logger.error("Error updating agrees to user research for user #{user.id}")

        # Raise and allow global exception handler to catch
        raise

      rescue Timeout::Error, Faraday::ClientError => e

        if retry_number < MAX_RETRIES

          retry_number += 1

          max_sleep_seconds = Float(2 ** retry_number)

          Rails.logger.info(
            "Will attempt update_agrees_to_user_research again, retry number #{retry_number} " \
            "after a sleeping for up to #{max_sleep_seconds} seconds"
          )

          sleep rand(0..max_sleep_seconds)

          retry

        else

          raise

        end

      end

    end

    private

    # Method to upsert a Salesforce Organisation record. Retries accounted for in outer scope call.
    #
    # @param [Organisation] organisation An instance of an Organisation object
    #
    # @return [String] A salesforce reference for the Organisation
    def create_organisation_in_salesforce(organisation)

      salesforce_organisation_reference = @client.upsert!(
        'Account',
        'Account_External_ID__c', 
        Name: organisation.name,
        Account_External_ID__c: organisation.id,
        BillingStreet: [organisation.line1, organisation.line2, organisation.line3].compact.join(', '),
        BillingCity: organisation.townCity,
        BillingState: organisation.county,
        BillingPostalCode: organisation.postcode,
        Company_Number__c: organisation.company_number,
        Charity_Number__c: organisation.charity_number,
        Charity_Number_NI__c: organisation.charity_number_ni,
        Organisation_Type__c: get_organisation_type_for_salesforce(organisation),
        Organisation_s_Mission_and_Objectives__c: convert_to_salesforce_mission_types(organisation.mission)
      )

      Rails.logger.info(
        "Created an Organisation record in Salesforce with reference: #{salesforce_organisation_reference}"
      )

      salesforce_organisation_reference

    end

    # Method to upsert a Salesforce Contact record. Retries accounted for in outer scope call.
    #
    # @param [User] user An instance of a User object
    # @param [String] salesforce_organisation_reference a salesforce organisation 
    #                                                   reference for the User's organisation
    #
    # @return [String] A Salesforce reference for the Contact/User
    def upsert_contact_in_salesforce(user, salesforce_organisation_reference)

      salesforce_contact_reference = @client.upsert!(
        'Contact',
        'Contact_External_ID__c',
        Contact_External_ID__c: user.id,
        LastName: user.name,
        Email: user.email,
        Email__c: user.email,
        Birthdate: user.date_of_birth,
        MailingStreet: [user.line1, user.line2, user.line3].compact.join(', '),
        MailingCity: user.townCity,
        MailingState: user.county,
        MailingPostalCode: user.postcode,
        Phone: user.phone_number,
        Other_communication_needs_for_contact__c: user.communication_needs,
        # Ensure we use a type of language preference known to Salesforce. If a different type, cover ourselves with both
        Language_Preference__c: (['english', 'welsh', 'both'].include? user.language_preference) ? user.language_preference : 'both',
        Agrees_To_User_Research__c: (user.agrees_to_user_research.present?) ? user.agrees_to_user_research : false,
        AccountId: salesforce_organisation_reference
       )

       Rails.logger.info(
         "Created a Contact record in Salesforce with reference: #{salesforce_contact_reference}"
        )

       salesforce_contact_reference

    end

    # Method to initialise a new Restforce client, called as part of object instantiation
    def initialise_client

      Rails.logger.info('Initialising Salesforce client')

      retry_number = 0
      
      begin

        @client = Restforce.new(
          username: Rails.configuration.x.salesforce.username,
          password: Rails.configuration.x.salesforce.password,
          security_token: Rails.configuration.x.salesforce.security_token,
          client_id: Rails.configuration.x.salesforce.client_id,
          client_secret: Rails.configuration.x.salesforce.client_secret,
          host: Rails.configuration.x.salesforce.host,
          api_version: '47.0'
        )

        Rails.logger.info('Finished initialising Salesforce client')

      rescue Timeout::Error, Faraday::ClientError => e

        if retry_number < MAX_RETRIES

          retry_number += 1

          max_sleep_seconds = Float(2 ** retry_number)

          Rails.logger.info(
            "Will attempt to initialise_client again, retry number #{retry_number} " \
            "after a sleeping for up to #{max_sleep_seconds} seconds"
          )

          sleep(rand(0..max_sleep_seconds))

          retry

        else

          raise

        end

      end

    end

    # Uses an organisation's org_type to create the salesforce equivalent
    # Use 'Other' in event of non match to so applicant not impacted.
    #
    # @param [Organisation] instance of Organisation
    #
    # @return [String] A salesforce version of an org type
    def get_organisation_type_for_salesforce(organisation)

      formatted_org_type_value = case organisation.org_type
      when 'registered_charity'
        'Registered charity'
      when 'local_authority'
        'Local authority'
      when 'registered_company', 'community_interest_company'
        'Registered company or Community Interest Company (CIC)'
      when 'faith_based_organisation', 'church_organisation'
        'Faith based or church organisation'
      when 'community_group', 'voluntary_group'
        'Community of Voluntary group' # Typo is present in Salesforce API name
      when 'individual_private_owner_of_heritage'
        'Private owner of heritage'
      when 'other_public_sector_organisation'
        'Other public sector organisation'
      when 'other'
        'Other organisation type'
      else
        'Other organisation type'
      end

    end

    # Rails stores mission types as a comma delimited set of strings.
    # Salesforce requires these to be a semi-colon delimited string.
    #
    # @param [Array] an array of mission strings for an Organisation
    #
    # @return [Array] A re-mapped array of missions formatted for Salesforce
    def convert_to_salesforce_mission_types(mission)

      salesforce_mission_array = mission.map { |mission_type| translate_mission_type_for_salesforce(mission_type) }

      salesforce_mission_array.compact.join(';')
        
    end

    # Function to change an Organisation's mission type to a Salesforce equivalent
    #
    # @param [String] mission_type for an Organisation
    #
    # @return [String] the mission string re-formatted for Saleforce
    def translate_mission_type_for_salesforce(mission_type)

      formatted_mission_value = case mission_type
      when 'black_or_minority_ethnic_led'
        'Black or minority ethnic-led'
      when 'disability_led'
        'Disability-led'
      when 'lgbt_plus_led'
        'LGBT+-led'
      when 'female_led'
        'Female-led'
      when 'young_people_led'
        'Young people-led'
      when 'mainly_catholic_community_led'
        'Mainly led by people from Catholic communities'
      when 'mainly_protestant_community_led'
        'Mainly led by people from Protestant communities'
      end

    end


    # Method to retrieve an expression of interest's reference from Salesforce
    #
    # @param [PaExpressionOfInterest] expression_of_interest An instance of PaExpressionOfInterest
    #
    # @return [String] expression_of_interest.Name A string representing the name/reference of 
    # the expression of interest
    def get_salesforce_expression_of_interest_reference(expression_of_interest)

      retry_number = 0

      begin

        salesforce_expression_of_interest = @client.find(
          'Expression_Of_Interest__c',
          expression_of_interest.id,
          'Expression_Of_Interest_external_ID__c'
        )

        salesforce_expression_of_interest.Name

      rescue Restforce::MatchesMultipleError, Restforce::UnauthorizedError,
             Restforce::EntityTooLargeError, Restforce::ResponseError => e

        Rails.logger.error("Error retrieving salesforce_expression_of_interest.Name " \
          "for expression of interest id #{expression_of_interest.id}")

        # Raise and allow global exception handler to catch
        raise

      rescue Timeout::Error, Faraday::ClientError => e

        if retry_number < MAX_RETRIES

          retry_number += 1

          max_sleep_seconds = Float(2 ** retry_number)

          Rails.logger.info(
            "Will attempt get_salesforce_expression_of_interest_reference again, retry number #{retry_number} " \
            "after a sleeping for up to #{max_sleep_seconds} seconds"
          )

          sleep rand(0..max_sleep_seconds)

          retry

        else

          raise

        end

      end

    end

  end

end
