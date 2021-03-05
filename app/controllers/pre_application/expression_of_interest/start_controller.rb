# Controller for the expression of interest 'start' page
class PreApplication::ExpressionOfInterest::StartController < ApplicationController
  include OrganisationHelper
  include PreApplicationHelper
  before_action :authenticate_user!

  # Method used to manage the creation and orchestration of the
  # PaExpressionOfInterest journey
  def update

    orchestrate_expression_of_interest_start_journey(current_user)
  
  end

  private

  # Method to orchestrate the expression of interest journey based on whether
  # they have an associated Organisation object with mandatory details
  # (for this journey type) populated.
  #
  # If no associated Organisation object exists, one is created.
  #
  # @param [User] user An instance of a User
  def orchestrate_expression_of_interest_start_journey(user)

    organisation = create_organisation_if_none_exists(user)

    create_pre_application_and_expression_of_interest(user, organisation)

    redirect_based_on_organisation_completeness(
      organisation,
      'pa_expression_of_interest'
    )

  end

  # Method responsible for creating a PreApplication object and
  # an associated PaExpressionOfInterest object
  #
  # @param [User] user An instance of a User
  # @param [Organisation] organisation An instance of an Organisation
  def create_pre_application_and_expression_of_interest(user, organisation)

    @pre_application = PreApplication.create(
      organisation_id: organisation.id,
      user_id: user.id
    )
  
    PaExpressionOfInterest.create(pre_application_id: @pre_application.id)

  end

end
