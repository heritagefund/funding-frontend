# Controller for the project enquiry 'working title' page
class PreApplication::ProjectEnquiry::WorkingTitleController < ApplicationController
  include PreApplicationContext, ObjectErrorsLogger

  # This method updates the working_title attribute of a pa_project_enquiry,
  # redirecting to :pre_application_project_enquiry_heritage_focus if successful and
  # re-rendering :show method if unsuccessful
  def update

    logger.info 'Updating working_title for ' \
                "pa_project_enquiry ID: #{@pre_application.pa_project_enquiry.id}"

    @pre_application.pa_project_enquiry.validate_working_title = true

    if @pre_application.pa_project_enquiry.update(pa_project_enquiry_params)

      logger.info 'Finished updating working_title for pa_project_enquiry ID: ' \
                  "#{@pre_application.pa_project_enquiry.id}"

      redirect_to(:pre_application_project_enquiry_heritage_focus)

    else

      logger.info 'Validation failed when attempting to update working_title ' \
                  " for pa_project_enquiry ID: #{@pre_application.pa_project_enquiry.id}"

      log_errors(@pre_application.pa_project_enquiry)

      render(:show)

    end
  
  end

  def pa_project_enquiry_params

    params.require(:pa_project_enquiry).permit(:working_title)

  end
  
end
