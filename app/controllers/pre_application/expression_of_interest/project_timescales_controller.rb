# Controller for the expression of interest 'project timescales' page
class PreApplication::ExpressionOfInterest::ProjectTimescalesController < ApplicationController
  include PreApplicationContext, ObjectErrorsLogger

  # This method updates the project_timescales attribute of a pa_expression_of_interest,
  # redirecting to :pre_application_expression_of_interest_overall_cost if successful and
  # re-rendering :show method if unsuccessful
  def update

    logger.info 'Updating project_timescales for ' \
                "pa_expression_of_interest ID: #{@pre_application.pa_expression_of_interest.id}"

    @pre_application.pa_expression_of_interest.validate_project_timescales = true

    if @pre_application.pa_expression_of_interest.update(pa_expression_of_interest_params)

      logger.info 'Finished updating project_timescales for pa_expression_of_interest ID: ' \
                  "#{@pre_application.pa_expression_of_interest.id}"

      redirect_to(:pre_application_expression_of_interest_overall_cost)

    else

      logger.info 'Validation failed when attempting to update project_timescales ' \
                  " for pa_expression_of_interest ID: #{@pre_application.pa_expression_of_interest.id}"

      log_errors(@pre_application.pa_expression_of_interest)

      render(:show)

    end
  
  end

  def pa_expression_of_interest_params

    params.require(:pa_expression_of_interest).permit(:project_timescales)

  end
  
end
