# Controller for the expression of interest 'what project does' page
class PreApplication::ExpressionOfInterest::WhatProjectDoesController < ApplicationController
  include PreApplicationContext, ObjectErrorsLogger

  # This method updates the what_project_does attribute of a pa_expression_of_interest,
  # redirecting to : pre_application_expression_of_interest_do_you_have_a_working_title
  # if successful and re-rendering :show method if unsuccessful
  def update

    logger.info 'Updating what_project_does for ' \
                "pa_expression_of_interest ID: #{@pre_application.pa_expression_of_interest.id}"

    @pre_application.pa_expression_of_interest.validate_what_project_does = true

    if @pre_application.pa_expression_of_interest.update(pa_expression_of_interest_params)

      logger.info 'Finished updating what_project_does for pa_expression_of_interest ID: ' \
                  "#{@pre_application.pa_expression_of_interest.id}"

      redirect_to(:pre_application_expression_of_interest_do_you_have_a_working_title)

    else

      logger.info 'Validation failed when attempting to update what_project_does ' \
                  " for pa_expression_of_interest ID: #{@pre_application.pa_expression_of_interest.id}"

      log_errors(@pre_application.pa_expression_of_interest)

      render(:show)

    end
  
  end

  def pa_expression_of_interest_params

    params.require(:pa_expression_of_interest).permit(:what_project_does)

  end
end
