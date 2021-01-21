# Controller for the expression of interest 'likely submission description' page
class PreApplication::ExpressionOfInterest::LikelySubmissionDescriptionController < ApplicationController
  include PreApplicationContext, ObjectErrorsLogger
  
  # This method updates the likely_submission_description attribute of a pa_expression_of_interest,
  # redirecting to :pre_application_expression_of_interest_check_your_answers if successful and
  # re-rendering :show method if unsuccessful
  def update

    logger.info 'Updating likely_submission_description for ' \
                "pa_expression_of_interest ID: #{@pre_application.pa_expression_of_interest.id}"

    @pre_application.pa_expression_of_interest.validate_likely_submission_description = true

    if @pre_application.pa_expression_of_interest.update(pa_expression_of_interest_params)

      logger.info 'Finished updating likely_submission_description for pa_expression_of_interest ID: ' \
                  "#{@pre_application.pa_expression_of_interest.id}"

      redirect_to(:pre_application_expression_of_interest_check_your_answers)

    else

      logger.info 'Validation failed when attempting to update likely_submission_description ' \
                  " for pa_expression_of_interest ID: #{@pre_application.pa_expression_of_interest.id}"

      log_errors(@pre_application.pa_expression_of_interest)

      render(:show)

    end
  
  end

  def pa_expression_of_interest_params

    params.require(:pa_expression_of_interest).permit(:likely_submission_description)

  end
    
end
