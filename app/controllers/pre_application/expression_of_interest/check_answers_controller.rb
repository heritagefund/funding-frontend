# Controller for the expression of interest 'check your answers' page
class PreApplication::ExpressionOfInterest::CheckAnswersController < ApplicationController
  include PreApplicationContext

  # This method redirects to :pre_application_expression_of_interest_submitted
  def update

    redirect_to(:pre_application_expression_of_interest_submitted)

  end

end
