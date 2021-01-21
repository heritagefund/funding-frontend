# Controller for the page that captures user details.
class User::DetailsController < ApplicationController
  before_action :authenticate_user!

  def update

    logger.debug "Updating user details for user ID: #{current_user.id}"

    current_user.validate_details = true

    current_user.update(user_params)

    if current_user.valid?

      # As current_user is valid, we can now merge the individual date of
      # birth fields into an individual Date object and store this in the
      # current_user's date_of_birth attribute

      current_user.date_of_birth = Date.new(
        params[:user][:dob_year].to_i,
        params[:user][:dob_month].to_i,
        params[:user][:dob_day].to_i
      )

      current_user.save

      logger.debug "Finished updating user details for user ID: #{current_user.id}"

      check_and_set_organisation(current_user)

      replicate_user_attributes_to_associated_person(current_user) if current_user.person_id

      redirect_to postcode_path 'user', current_user.organisations.first.id

    else

      logger.debug "Validation failed when updating user details for user ID: #{current_user.id}"

      store_values_in_flash

      render :show

      # Clear the flash to ensure that we do not show flashed values upon
      # revisiting the page
      flash.discard

    end

  end

  private

  # Temporarily stores values in FlashHash to redisplay if there
  # have been any errors - this is necessary as we don't have
  # model attributes that are persistent for the individual date
  # items.
  def store_values_in_flash
    params[:user].each do |key, value|
      flash[key] = value.empty? ? '' : value
    end
  end

  # Checks whether the user is linked to an organisation and creates one if
  # not. This caters to a case where the user has been registered but the
  # organisation has not been created yet (prior to organisation creation
  # being moved to the User::RegistrationsController)
  #
  # @param [User] user An instance of User
  def check_and_set_organisation(user)

    return if user.organisations.any?

    user.organisations.create

  end

  # Replicates a subset of attributes from the passed in User object
  # to the User's associated Person record
  #
  # @param [User] user An instance of User
  def replicate_user_attributes_to_associated_person(user)

    person = Person.find(user.person_id)

    person.update(
      name: user.name,
      date_of_birth: user.date_of_birth,
      phone_number: user.phone_number
    )

  end

  def user_params
    params.require(:user).permit(
      :name,
      :dob_day,
      :dob_month,
      :dob_year,
      :phone_number,
      :communication_needs,
      :language_preference
    )
  end

end
