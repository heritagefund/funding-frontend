# Controller for the project enquiry 'working title' page
class PreApplication::ExpressionOfInterest::WorkingTitleController < ApplicationController
  include PreApplicationContext, ObjectErrorsLogger

  # This method updates the working_title attribute of a pa_expression_of_interest,
  # redirecting to :pre_application_project_enquiry_programme_outcomes if successful and
  # re-rendering :show method if unsuccessful
  def update

    logger.info 'Updating working_title for pa_expression_of_interest ' \
                "ID: #{@pre_application.pa_expression_of_interest.id}"

    @pre_application.pa_expression_of_interest.validate_working_title = true

    if @pre_application.pa_expression_of_interest.update(pa_expression_of_interest_params)

      logger.info 'Finished updating working_title for pa_expression_of_interest ID: ' \
                  "#{@pre_application.pa_expression_of_interest.id}"

      redirect_to(:pre_application_expression_of_interest_programme_outcomes)

    else

      logger.info 'Validation failed when attempting to update working_title ' \
                  " for pa_expression_of_interest ID: #{@pre_application.pa_expression_of_interest.id}"

      log_errors(@pre_application.pa_expression_of_interest)

      render(:show)

    end
  
  end

  def pa_expression_of_interest_params

    params.require(:pa_expression_of_interest).permit(:working_title)

  end
  
end
