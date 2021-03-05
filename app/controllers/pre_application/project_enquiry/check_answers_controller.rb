# Controller for the project enquiry 'check answers' page
class PreApplication::ProjectEnquiry::CheckAnswersController < ApplicationController
  include PreApplicationContext 
  include PreApplicationHelper

  def show
    @organisation = Organisation.find(@pre_application.organisation_id)
  end

  # This method starts the process of creating an expression of interest object in Salesforce
  # and then redirects to :pre_application_project_enquiry_submitted
  def update

    send_pre_application_to_salesforce(
      @pre_application, 
      current_user, 
      current_user.organisations.first
    )

    redirect_to(:pre_application_project_enquiry_submitted)

  end

end
