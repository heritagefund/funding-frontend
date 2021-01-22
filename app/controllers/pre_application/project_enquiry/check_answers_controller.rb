# Controller for the project enquiry 'check answers' page
class PreApplication::ProjectEnquiry::CheckAnswersController < ApplicationController
  include PreApplicationContext 

  # This method queues submission of a PreApplicationToSalesforceJob and then
  # redirects to :pre_application_project_enquiry_submitted
  def update

    PreApplicationToSalesforceJob.perform_later(@pre_application)

    redirect_to(:pre_application_project_enquiry_submitted)

  end

end
