# Controller for the expression of interest 'previous contact name' page
class PreApplication::ExpressionOfInterest::PreviousContactNameController < ApplicationController
  include PreApplicationContext, ObjectErrorsLogger

  # This method updates the previous_contact_name attribute of a pa_expression_of_interest,
  # redirecting to :pre_application_expression_of_interest_what_will_the_project_do if successful and
  # re-rendering :show method if unsuccessful
  def update

    logger.info 'Updating previous_contact_name for ' \
                "pa_expression_of_interest ID: #{@pre_application.pa_expression_of_interest.id}"

    if @pre_application.pa_expression_of_interest.update(pa_expression_of_interest_params)

      logger.info 'Finished updating previous_contact_name for pa_expression_of_interest ID: ' \
                  "#{@pre_application.pa_expression_of_interest.id}"

      redirect_to(:pre_application_expression_of_interest_what_will_the_project_do)

    else

      logger.info 'Validation failed when attempting to update previous_contact_name ' \
                  " for pa_expression_of_interest ID: #{@pre_application.pa_expression_of_interest.id}"

      log_errors(@pre_application.pa_expression_of_interest)

      render(:show)

    end
  
  end

  def pa_expression_of_interest_params

    params.require(:pa_expression_of_interest).permit(:previous_contact_name)

  end
  
end
