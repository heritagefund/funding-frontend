# Controller for the expression of interest 'programme outcomes' page
class PreApplication::ExpressionOfInterest::ProgrammeOutcomesController < ApplicationController
  include PreApplicationContext, ObjectErrorsLogger
  
  # This method updates the programme_outcomes attribute of a pa_expression_of_interest,
  # redirecting to :pre_application_expression_of_interest_heritage_focus if successful and
  # re-rendering :show method if unsuccessful
  def update

    logger.info 'Updating programme_outcomes for ' \
                "pa_expression_of_interest ID: #{@pre_application.pa_expression_of_interest.id}"

    @pre_application.pa_expression_of_interest.validate_programme_outcomes = true

    if @pre_application.pa_expression_of_interest.update(pa_expression_of_interest_params)

      logger.info 'Finished updating programme_outcomes for pa_expression_of_interest ID: ' \
                  "#{@pre_application.pa_expression_of_interest.id}"

      redirect_to(:pre_application_expression_of_interest_heritage_focus)

    else

      logger.info 'Validation failed when attempting to update programme_outcomes ' \
                  " for pa_expression_of_interest ID: #{@pre_application.pa_expression_of_interest.id}"

      log_errors(@pre_application.pa_expression_of_interest)

      render(:show)

    end
  
  end

  def pa_expression_of_interest_params

    params.require(:pa_expression_of_interest).permit(:programme_outcomes)

  end

end
