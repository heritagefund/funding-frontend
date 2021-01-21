# Controller for the expression of interest 'potential funding amount' page
class PreApplication::ExpressionOfInterest::PotentialFundingAmountController < ApplicationController
  include PreApplicationContext, ObjectErrorsLogger
  
  # This method updates the potential_funding_amount attribute of a pa_expression_of_interest,
  # redirecting to :pre_application_project_enquiry_likely_cost if successful and
  # re-rendering :show method if unsuccessful
  def update

    logger.info 'Updating potential_funding_amount for ' \
                "pa_expression_of_interest ID: #{@pre_application.pa_expression_of_interest.id}"

    @pre_application.pa_expression_of_interest.validate_potential_funding_amount = true

    if @pre_application.pa_expression_of_interest.update(pa_expression_of_interest_params)

      logger.info 'Finished updating potential_funding_amount for pa_expression_of_interest ID: ' \
                  "#{@pre_application.pa_expression_of_interest.id}"

      redirect_to(:pre_application_expression_of_interest_likely_submission_description)

    else

      logger.info 'Validation failed when attempting to update potential_funding_amount ' \
                  " for pa_expression_of_interest ID: #{@pre_application.pa_expression_of_interest.id}"

      log_errors(@pre_application.pa_expression_of_interest)

      render(:show)

    end
  
  end

  def pa_expression_of_interest_params

    params.require(:pa_expression_of_interest).permit(:potential_funding_amount)

  end
    
end
