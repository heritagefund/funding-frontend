# Controller for the expression of interest 'submitted' page
class PreApplication::ExpressionOfInterest::SubmittedController < ApplicationController
  include ObjectErrorsLogger
  include PreApplicationContext
  include PreApplicationHelper

  # This method updates the agrees_to_contact and agrees_to_user_research
  # attributes of a user, re-rendering the :show method with either a
  # notification or errors depending on success
  def update

    logger.info "Updating preferences for user ID: #{current_user.id}"

    if current_user.update(user_params)

      send_pre_application_user_preferences_to_salesforce(@pre_application, current_user)

      logger.info("Finished updating preferences for user ID: #{current_user.id}")

      flash[:user_preferences_success] = true

      render(:show)

      flash[:user_preferences_success] = nil

    else

      logger.info("Validation failed when updating preferences for user ID: #{current_user.id}")

      log_errors(current_user)

      render(:show)

    end

  end

  private

  def user_params
    params.require(:user).permit(:agrees_to_contact, :agrees_to_user_research)
  end

end
