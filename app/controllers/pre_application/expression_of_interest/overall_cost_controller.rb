# Controller for the expression of interest 'overall cost' page
class PreApplication::ExpressionOfInterest::OverallCostController < ApplicationController
  include PreApplicationContext, ObjectErrorsLogger

  # This method updates the overall_cost attribute of a pa_expression_of_interest,
  # redirecting to :pre_application_expression_of_interest_likely_ask if successful and
  # re-rendering :show method if unsuccessful
  def update

    logger.info 'Updating overall_cost for ' \
                "pa_expression_of_interest ID: #{@pre_application.pa_expression_of_interest.id}"

    @pre_application.pa_expression_of_interest.validate_overall_cost = true

    if @pre_application.pa_expression_of_interest.update(pa_expression_of_interest_params)

      logger.info 'Finished updating overall_cost for pa_expression_of_interest ID: ' \
                  "#{@pre_application.pa_expression_of_interest.id}"

      redirect_to(:pre_application_expression_of_interest_likely_ask)

    else

      logger.info 'Validation failed when attempting to update overall_cost ' \
                  " for pa_expression_of_interest ID: #{@pre_application.pa_expression_of_interest.id}"

      log_errors(@pre_application.pa_expression_of_interest)

      render(:show)

    end
  
  end

  def pa_expression_of_interest_params

    params.require(:pa_expression_of_interest).permit(:overall_cost)

  end
    
end
