# Controller for the expression of interest 'heritage focus' page
class PreApplication::ExpressionOfInterest::HeritageFocusController < ApplicationController
  include PreApplicationContext, ObjectErrorsLogger

  # This method updates the heritage_focus attribute of a pa_expression_of_interest,
  # redirecting to :pre_application_expression_of_interest_what_is_the_need_for_this_project
  # if successful and re-rendering :show method if unsuccessful
  def update

    logger.info 'Updating heritage_focus for ' \
                "pa_expression_of_interest ID: #{@pre_application.pa_expression_of_interest.id}"

    @pre_application.pa_expression_of_interest.validate_heritage_focus = true

    if @pre_application.pa_expression_of_interest.update(pa_expression_of_interest_params)

      logger.info 'Finished updating heritage_focus for pa_expression_of_interest ID: ' \
                  "#{@pre_application.pa_expression_of_interest.id}"

      redirect_to(:pre_application_expression_of_interest_what_is_the_need_for_this_project)

    else

      logger.info 'Validation failed when attempting to update heritage_focus ' \
                  " for pa_expression_of_interest ID: #{@pre_application.pa_expression_of_interest.id}"

      log_errors(@pre_application.pa_expression_of_interest)

      render(:show)

    end
  
  end

  def pa_expression_of_interest_params

    params.require(:pa_expression_of_interest).permit(:heritage_focus)

  end
  
end
