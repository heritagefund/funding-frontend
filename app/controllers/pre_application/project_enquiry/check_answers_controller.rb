# Controller for the project enquiry 'check answers' page
class PreApplication::ProjectEnquiry::CheckAnswersController < ApplicationController
  include PreApplicationContext 

  # This method redirects to :pre_application_project_enquiry_submitted
  def update

    redirect_to(:pre_application_project_enquiry_submitted)

  end

end
