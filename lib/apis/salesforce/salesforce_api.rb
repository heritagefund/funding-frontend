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

        salesforce_account_id = create_organisation_in_salesforce(organisation)

        salesforce_contact_id = upsert_contact_in_salesforce(user, salesforce_account_id)

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
          Contact__c: salesforce_contact_id,
          Name_of_your_organisation__c: salesforce_account_id
        )

        Rails.logger.info(
          'Created an expression of interest record in Salesforce with ' \
          "reference: #{salesforce_expression_of_interest_id}"
        )

        {
          salesforce_account_id: salesforce_account_id,
          salesforce_contact_id: salesforce_contact_id,
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
        
        salesforce_account_id = create_organisation_in_salesforce(organisation)

        salesforce_contact_id = upsert_contact_in_salesforce(user, salesforce_account_id)

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
          Contact__c: salesforce_contact_id,
          Name_of_your_organisation__c: salesforce_account_id
        )
 
        Rails.logger.info(
          "Created a project enquiry record in Salesforce with reference: #{salesforce_project_enquiry_reference}"
        )

        {
          salesforce_account_id: salesforce_account_id,
          salesforce_contact_id: salesforce_contact_id,
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

    # Method to upsert a Salesforce Organisation record. Calling function should handle exceptions/retries
    #
    # @param [Organisation] organisation An instance of an Organisation object
    #
    # @return [String] A salesforce id for the Account (Organisation is an alias of Account)
    def create_organisation_in_salesforce(organisation)
      
      salesforce_account_id = find_matching_account_for_organisation(organisation)

      if salesforce_account_id.nil?
        salesforce_account_id = upsert_account_by_organisation_id(organisation)
      else
        upsert_account_by_salesforce_id(organisation, salesforce_account_id)    
      end

      Rails.logger.info(
        "Upserted an Account record in Salesforce with reference: #{salesforce_account_id}"
      )

      salesforce_account_id

    end

    # Upserts to an Account record in Salesforce using the organisation.id
    # Calling function should handle exceptions/retries
    #
    # @param [Organisation] organisation An instance of a Organisation object
    #
    # @return [String] salesforce_account_id A Salesforce Account Id for the Organisation
    def upsert_account_by_organisation_id(organisation)
      @client.upsert!(
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
    end

    # Upserts to an Account record in Salesforce using the salesforce Account Id
    # Calling function should handle exceptions/retries
    #
    # @param [Organisation] organisation An instance of a Organisation object
    # @param [String] salesforce_account_id A salesforce Account Id 
    #                                       for the User's organisation
    #
    # @return [String] salesforce_account_id A Salesforce Account Id for the Organisation
    def upsert_account_by_salesforce_id(organisation, salesforce_account_id)
      @client.upsert!(
        'Account',
        'Id', 
        Id: salesforce_account_id,
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
    end

    # Method to orchestrate upserting a Salesforce Contact record. 
    # Tries to find an existing Contact record in Salesforce first.
    # Then calls an appropriate upsert.  Upserts by Salesforce's
    # Contact Id if known.  Otherwise upserts by the User objects id.
    # Calling function should handle exceptions/retries
    #
    # @param [User] user An instance of a User object
    # @param [String] salesforce_account_id a salesforce organisation 
    #                                                   reference for the User's organisation
    #
    # @return [String] salesforce_contact_id A Salesforce contact Id for the Contact/User
    def upsert_contact_in_salesforce(user, salesforce_account_id)
      
      salesforce_contact_id = find_matching_contact_for_user(user)

      if salesforce_contact_id.nil?
        salesforce_contact_id = upsert_contact_by_user_id(user, salesforce_account_id)       
      else
        upsert_contact_by_salesforce_id(user, salesforce_contact_id, salesforce_account_id)    
      end

      Rails.logger.info(
        "Upserted a Contact record in Salesforce with Id: #{salesforce_contact_id}"
      )

      salesforce_contact_id

    end

    # Upserts to a Contact record in Salesforce using the Contact record's Id
    # Removes the FirstName, MiddleName, Suffix attributes, and 
    # populates LastName with the User.name value from Funding Frontend
    # Calling function should handle exceptions/retries
    #
    # @param [User] user An instance of a User object
    # @param [String] salesforce_contact_id The Contact record's Id
    # @param [String] salesforce_account_id A salesforce organisation 
    #                                                   reference for the User's organisation
    # @return [String] salesforce_contact_id A Salesforce contact Id for the Contact/User
    def upsert_contact_by_salesforce_id(user, salesforce_contact_id, salesforce_account_id) 
      salesforce_contact_id = @client.upsert!(
        'Contact',
        'Id',
        Id: salesforce_contact_id,
        Contact_External_ID__c: user.id,
        Salutation: '',
        FirstName: '',
        MiddleName: '',
        Suffix: '',
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
        AccountId: salesforce_account_id
       ) 
    end 

    # Upserts to a Contact record in Salesforce using the User instance's id
    # Removes the Salutation, FirstName, MiddleName, Suffix attributes, and 
    # populates LastName with the User.name value from Funding Frontend
    # Calling function should handle exceptions/retries
    #
    # @param [User] user An instance of a User object
    # @param [String] salesforce_account_id A salesforce organisation 
    #                                                   reference for the User's organisation
    def upsert_contact_by_user_id(user, salesforce_account_id) 
      salesforce_contact_id = @client.upsert!(
        'Contact',
        'Contact_External_ID__c',
        Contact_External_ID__c: user.id,
        Salutation: '',
        FirstName: '',
        MiddleName: '',
        Suffix: '',
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
        AccountId: salesforce_account_id
       ) 
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

    # Method check Salesforce for existing Contact records for the passed User instance
    # Firstly checks if a Contact record exists with an external ID matching the user.id
    # If no match found, then tries to find a Contact record with a matching email
    # A Salesforce Id for the Contact record is returned if a match is made.  Otherwise nil.
    # Calling function should handle exceptions/retries
    #
    # @param [User] user An instance of User which is the current user
    #
    # @return [String] contact_salesforce_id A string representing Salesforce Id 
    #                                        for the Contact record, or nil
    def find_matching_contact_for_user(user)
      
      begin

        contact_salesforce_id =  @client.find(
          'Contact',
          user.id,
          'Contact_External_ID__c'
        ).Id

      rescue Restforce::NotFoundError
        Rails.logger.info("Unable to find contact with external id #{user.id} " \
          "will attempt to find contact using a name and Email match")  
      end
      
      unless contact_salesforce_id 

        contact_collection_from_salesforce = 
          @client.query_all("select Id from Contact where Email = '#{user.email}'")

        contact_salesforce_id = contact_collection_from_salesforce&.first&.Id

      end

      Rails.logger.info("Unable to find contact with matching name and email for "\
        "user id #{user.id}") if contact_salesforce_id.nil?
      
      contact_salesforce_id

    end

    # Method check Salesforce for existing Account (Organisation) records for the passed 
    # Organisation instance.
    # Firstly checks if an Account record exists with an external ID matching the organisation.id
    # If no match found, then tries to find a Account record with a matching 
    # organisation name and postcode combination.  
    # A Salesforce Id for the Account record is returned if a match is made.  Otherwise nil.
    # Calling function should handle exceptions/retries.
    #
    # @param [Organisation] organisation An instance of Organisation which is the 
    # organisation for the current user.
    #
    # @return [String] Account_salesforce_id A string representing Salesforce Id 
    #                                        for the Account record, or nil
    def find_matching_account_for_organisation(organisation)
      
      begin

        account_salesforce_id =  @client.find(
          'Account',
          organisation.id,
          'Account_External_ID__c'
        ).Id

      rescue Restforce::NotFoundError
        Rails.logger.info("Unable to find account with external id #{organisation.id} " \
          "will attempt to find account using a name and postcode match")  
      end
      
      unless account_salesforce_id 
        
        # Ruby unusual in its approach to escaping.  This is the regex approach other devs adopt: 
        # https://github.com/restforce/restforce/issues/314
        escaped_org_name = organisation.name.gsub(/[']/,"\\\\'")
    
        account_collection_from_salesforce = 
          @client.query_all("select Id from Account where name = '#{escaped_org_name}' and BillingPostalCode = '#{organisation.postcode}'")

        account_salesforce_id = account_collection_from_salesforce&.first&.Id

      end

      Rails.logger.info("Unable to find account with matching name and postcode for "\
        "organisation id #{organisation.id}") if account_salesforce_id.nil?
      
      account_salesforce_id

    end

  end

end
