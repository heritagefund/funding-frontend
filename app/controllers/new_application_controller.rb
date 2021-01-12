# Controller responsible for orchestrating the journey for a user
# who has selected to create a new application
class NewApplicationController < ApplicationController
  include ObjectErrorsLogger

  # If the current_user has no linked organisation, or if their linked organisation
  # does not contain all mandatory details, then redirect to the dashboard
  # orchestration path. Otherwise, proceed to create a NewApplication object
  def show

    redirect_based_on_organisation_presence_and_completeness(current_user)

    @application = NewApplication.new

  end

  # This method creates a new NewApplication object and then uses this to
  # validate the application_type selected on the user. If validation passes,
  # then the user is redirected to the application start page relevant to
  # the application_type selected. Otherwise, :show is re-rendered
  def update

    logger.info "Updating application_type for user ID: #{current_user.id}"

    @application = NewApplication.new

    @application.validate_application_type_presence = true

    @application.update(new_application_params)

    if @application.valid?

      logger.info "Finished updating application_type for user ID: #{current_user.id}"

      redirect_to_application_start_page(@application)

    else

      logger.info 'Validation failed when attempting to select application_type ' \
                    "for user ID: #{current_user.id}"

      log_errors(@application)

      render :show

    end

  end

  private

  def new_application_params

    params.fetch(:new_application, {}).permit(:application_type)

  end

  # Redirects the user based on the presence of and completeness of their
  # associated organisation. If not present or incomplete, we redirect to
  # the dashboard orchestration route
  #
  # @param [User] user An instance of User
  def redirect_based_on_organisation_presence_and_completeness(user)

    unless user.organisations.any? &&
           helpers.complete_organisation_details?(user.organisations.first)
      redirect_to :orchestrate_dashboard_journey
    end

  end

  # This method will redirect the user to the correct application start page
  # based on the application_type that they have selected
  #
  # @param [NewApplication] application An instance of NewApplication
  def redirect_to_application_start_page(application)

    case application.application_type

    when 'sff_small'

      logger.info "Redirecting to SFF Small form for user ID: #{current_user.id}"

      redirect_to :funding_application_gp_project_start

    else
      logger.info 'Method redirect_to_application_start_page called with ' \
                  'an application object containing an ' \
                  "application_type of #{application.application_type}"

      # If the user has managed to hit this route with an invalid
      # application_type, then we should redirect them back to root
      redirect_to :authenticated_root

    end

  end

end
