# Controller for the project enquiry 'submitted' page
class PreApplication::ProjectEnquiry::SubmittedController < ApplicationController
  include PreApplicationContext, ObjectErrorsLogger


  # This method updates the agrees_to_contact and agrees_to_user_research
  # attributes of a user, re-rendering the :show method with either a
  # notification or errors depending on success
  def update

    logger.info "Updating preferences for user ID: #{current_user.id}"

    if current_user.update(user_params)

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
