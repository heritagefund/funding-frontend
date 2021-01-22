# Controller for the expression of interest 'check your answers' page
class PreApplication::ExpressionOfInterest::CheckAnswersController < ApplicationController
  include PreApplicationContext

  # This method queues submission of a PreApplicationToSalesforceJob and then
  # redirects to :pre_application_expression_of_interest_submitted
  def update

    PreApplicationToSalesforceJob.perform_later(@pre_application)

    redirect_to(:pre_application_expression_of_interest_submitted)

  end

end
