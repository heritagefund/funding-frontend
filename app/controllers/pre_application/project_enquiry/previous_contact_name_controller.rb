# Controller for the project enquiry 'previous contact name' page
class PreApplication::ProjectEnquiry::PreviousContactNameController < ApplicationController
  include PreApplicationContext, ObjectErrorsLogger

  # This method updates the previous_contact_name attribute of a pa_project_enquiry,
  # redirecting to :pre_application_project_enquiry_what_is_the_need_for_this_project
  # if successful and re-rendering :show method if unsuccessful
  def update

    logger.info 'Updating previous_contact_name for ' \
                "pa_project_enquiry ID: #{@pre_application.pa_project_enquiry.id}"

    if @pre_application.pa_project_enquiry.update(pa_project_enquiry_params)

      logger.info 'Finished updating previous_contact_name for pa_project_enquiry ID: ' \
                  "#{@pre_application.pa_project_enquiry.id}"

      redirect_to(:pre_application_project_enquiry_what_is_the_need_for_this_project)

    else

      logger.info 'Validation failed when attempting to update previous_contact_name ' \
                  " for pa_project_enquiry ID: #{@pre_application.pa_project_enquiry.id}"

      log_errors(@pre_application.pa_project_enquiry)

      render(:show)

    end
  
  end

  def pa_project_enquiry_params

    params.require(:pa_project_enquiry).permit(:previous_contact_name)

  end
  
end
