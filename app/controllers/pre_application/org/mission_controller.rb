# Controller for a page that asks about the mission, or objectives, of an organisation.
class PreApplication::Org::MissionController < ApplicationController
    include OrganisationContext
    include ObjectErrorsLogger
    include PreApplicationContext
  
    # This method updates the mission attribute of an organisation,
    # redirecting to :organisation_signatories if successful and re-rendering
    # :show method if unsuccessful
    def update
  
      logger.info "Updating mission for organisation ID: #{@organisation.id}"
  
      @organisation.validate_mission = true
  
      @organisation.update(organisation_params)
  
      if @organisation.valid?
  
        logger.info "Finished updating mission for organisation ID: #{@organisation.id}"
  
        redirect_to :pre_application_project_enquiry_previous_contact if @pre_application.pa_project_enquiry.present?
        redirect_to :pre_application_expression_of_interest_previous_contact if @pre_application.pa_expression_of_interest.present?
  
      else
  
        logger.info "Validation failed when attempting to update mission for organisation ID: #{@organisation.id}"
  
        log_errors(@organisation)
  
        render :show
  
      end
  
    end
  
    private
  
    def organisation_params
  
      params.fetch(:organisation, {}).permit(:mission, mission: [])
  
    end
  
  end
  