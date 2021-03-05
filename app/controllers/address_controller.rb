# Controller class for address-related functionality. Provides the ability
# to update address details for User, Project and Organisation model
# objects.
class AddressController < ApplicationController
  include ObjectErrorsLogger
  include PostcodeLookup
  before_action :authenticate_user!, :check_and_set_model_type

  def assign_address_attributes

    assign_attributes(@model_object)

    render :show

  end

  # This method updates the address for a given model object, which could
  # be of types user, organisation or project. If of type user, then the
  # address attributes are replicated to a separate address record which is
  # then associated with the user and it's associated person record
  def update

    logger.info "Updating address for #{@type} ID: #{@model_object.id}"

    @model_object.validate_address = true

    @model_object.update(model_params)

    if @model_object.valid?

      logger.info "Finished updating address for #{@type} ID: " \
                  "#{@model_object.id}"

      if @type == 'organisation'

        redirect_to organisation_mission_path(params['id'])

      elsif @type == 'preapplication'

        redirect_to(
          pre_application_organisation_mission_path(
            pre_application_id: params['id'],
            organisation_id: @model_object.id
          )
        )

      elsif @type == 'project'

        redirect_to funding_application_gp_project_description_path(@model_object.funding_application.id)

      elsif @type == 'user'

        # Caters to a situation where original applicants have no person assigned to the user.
        check_and_set_person_address(@model_object) if @model_object.person.present?

        redirect_to :authenticated_root

      end

    else

      logger.info 'Validation failed when attempting to update address for ' \
                  "#{@type} ID: #{@model_object.id}"

      log_errors(@model_object)

      render :show

    end

  end

  private

  # Checks for a known type of model in the params.
  # If correct, then assign the model type to a @type instance variable.
  def check_and_set_model_type
    if %w[user organisation project preapplication].include? params[:type]
      @type = params[:type]
      case @type
      when 'organisation'
        @model_object = Organisation.find(params[:id])
      when 'project'
        @model_object = Project.find(params[:id])
      when 'user'
        users_organisation = UsersOrganisation.find_by(organisation_id: params[:id])
        @model_object = current_user
        redirect_to :root unless users_organisation.user_id == current_user.id
      when 'preapplication'
        # When @type is 'preapplication', we need to actually set the
        # address against the associated Organisation object
        pre_application = PreApplication.find(params[:id])
        @model_object = Organisation.find(pre_application.organisation_id)
      end
    else
      redirect_to :root
    end
  end

  # Checks for the presence of an associated Address via the PeopleAddresses
  # model. If none exists, a new Address and PeopleAddress is created. Address
  # details are replicated from the current_user object
  #
  # @param [User] user An instance of User
  def check_and_set_person_address(user)

    person_address_association = PeopleAddress.find_by(person_id: user.person_id)

    unless person_address_association

      logger.debug "No people_addresses record found for person ID: #{user.person_id}"

      address = Address.create

      logger.debug "addresses record created with ID: #{address.id}"

      person_address_association = create_person_address_association(user.person_id, address.id)

    end

    replicate_address_from_current_user_details(person_address_association.address_id, user)

  end

  # Creates and returns a new Address object based on the
  # attributes stored against the User argument
  #
  # @param [uuid] id The unique identifier of an Address
  # @param [User] user An instance of User
  def replicate_address_from_current_user_details(id, user)

    address = Address.find(id)

    address.update(
      line1: user.line1,
      line2: user.line2,
      line3: user.line3,
      town_city: user.townCity,
      county: user.county,
      postcode: user.postcode
    )

  end

  # Creates and returns a PeopleAddress object based on the
  # Address and User arguments passed
  #
  # @param [uuid] person_id The unique identifier of a Person
  # @param [uuid] address_id The unique identifier of an Address
  def create_person_address_association(person_id, address_id)

    logger.debug "Creating people_addresses record for person ID: #{person_id} " \
      "and address ID: #{address_id}"

    person_address_association = PeopleAddress.create(
      person_id: person_id,
      address_id: address_id
    )

    logger.debug "people_addresses record created with ID: #{person_address_association.id}"

    person_address_association

  end

  def model_params

    # Ensure that the required param is set to either the @type value,
    # or 'organisation' if @type is equal to 'preapplication'. We do
    # this to ensure that during a pre-application journey, we don't
    # require a param of 'preapplication', when we are actually dealing
    # with an organisation object
    model_type = @type == 'preapplication' ? 'organisation' : @type

    params.require(model_type)
          .permit(:name, :line1, :line2, :line3,
                  :townCity, :county, :postcode)
  end

end
