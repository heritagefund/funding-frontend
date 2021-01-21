# Controller for the project enquiry 'project reasons' page
class PreApplication::ProjectEnquiry::ProjectReasonsController < ApplicationController
  include PreApplicationContext, ObjectErrorsLogger

  # This method updates the project_reasons attribute of a pa_project_enquiry,
  # redirecting to :pre_application_project_enquiry_what_will_the_project_do if successful and
  # re-rendering :show method if unsuccessful
  def update

    logger.info 'Updating project_reasons for ' \
                "pa_project_enquiry ID: #{@pre_application.pa_project_enquiry.id}"

    @pre_application.pa_project_enquiry.validate_project_reasons = true

    if @pre_application.pa_project_enquiry.update(pa_project_enquiry_params)

      logger.info 'Finished updating project_reasons for pa_project_enquiry ID: ' \
                  "#{@pre_application.pa_project_enquiry.id}"

      redirect_to(:pre_application_project_enquiry_what_will_the_project_do)

    else

      logger.info 'Validation failed when attempting to update project_reasons ' \
                  " for pa_project_enquiry ID: #{@pre_application.pa_project_enquiry.id}"

      log_errors(@pre_application.pa_project_enquiry)

      render(:show)

    end
  
  end

  def pa_project_enquiry_params

    params.require(:pa_project_enquiry).permit(:project_reasons)

  end
  
end
