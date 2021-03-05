# Controller for the project enquiry 'start' page
class PreApplication::ProjectEnquiry::StartController < ApplicationController
  include OrganisationHelper
  include PreApplicationHelper
  before_action :authenticate_user!

  # Method used to manage the creation and orchestration of the
  # PaProjectEnquiry journey
  def update
  
    orchestrate_project_enquiry_start_journey(current_user)
  
  end

  private
  
  # Method to orchestrate the project enquiry journey based on whether
  # they have an associated Organisation object with mandatory details
  # (for this journey type) populated.
  #
  # If no associated Organisation object exists, one is created.
  #
  # @param [User] user An instance of a User
  def orchestrate_project_enquiry_start_journey(user)

    organisation = create_organisation_if_none_exists(user)

    create_pre_application_and_project_enquiry(user, organisation)

    redirect_based_on_organisation_completeness(
      organisation,
      'pa_project_enquiry'
    )

  end

  # Method responsible for creating a PreApplication object and
  # an associated PaProjectEnquiry object
  #
  # @param [User] user An instance of a User
  # @param [Organisation] organisation An instance of an Organisation
  def create_pre_application_and_project_enquiry(user, organisation)

    @pre_application = PreApplication.create(
      organisation_id: organisation.id,
      user_id: user.id
    )
  
    PaProjectEnquiry.create(pre_application_id: @pre_application.id)

  end

end
