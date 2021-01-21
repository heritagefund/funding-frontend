# Controller for the expression of interest 'project reasons' page
class PreApplication::ExpressionOfInterest::ProjectReasonsController < ApplicationController
  include PreApplicationContext, ObjectErrorsLogger

  # This method updates the project_reasons attribute of a pa_expression_of_interest,
  # redirecting to :pre_application_expression_of_interest_timescales if successful and
  # re-rendering :show method if unsuccessful
  def update

    logger.info 'Updating project_reasons for ' \
                "pa_expression_of_interest ID: #{@pre_application.pa_expression_of_interest.id}"

    @pre_application.pa_expression_of_interest.validate_project_reasons = true

    if @pre_application.pa_expression_of_interest.update(pa_expression_of_interest_params)

      logger.info 'Finished updating project_reasons for pa_expression_of_interest ID: ' \
                  "#{@pre_application.pa_expression_of_interest.id}"

      redirect_to(:pre_application_expression_of_interest_timescales)

    else

      logger.info 'Validation failed when attempting to update project_reasons ' \
                  " for pa_expression_of_interest ID: #{@pre_application.pa_expression_of_interest.id}"

      log_errors(@pre_application.pa_expression_of_interest)

      render(:show)

    end
  
  end

  def pa_expression_of_interest_params

    params.require(:pa_expression_of_interest).permit(:project_reasons)

  end
  
end
