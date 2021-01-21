# Controller for the expression of interest 'start' page
class PreApplication::ExpressionOfInterest::StartController < ApplicationController
  before_action :authenticate_user!

  # Method used to create new PreApplication and PaExpressionOfInterest objects
  # before redirecting the user to 
  # :pre_application_pa_expression_of_interest_previous_contact_path
  def update
  
    @pre_application = PreApplication.create(
      organisation_id: current_user.organisations.first.id,
      user_id: current_user.id
    )
  
    PaExpressionOfInterest.create(pre_application_id: @pre_application.id)
  
    redirect_to(
      pre_application_expression_of_interest_previous_contact_path(
        @pre_application.id
      )
    )
  
  end

end
