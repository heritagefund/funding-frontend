module OrganisationHelper

  # Checks for the presence of mandatory organisation parameters,
  # returning false if any are not present and true if all are
  # present
  #
  # @param [Organisation] organisation An instance of Organisation
  def complete_organisation_details?(organisation)

    [
        organisation.name.present?,
        organisation.line1.present?,
        organisation.townCity.present?,
        organisation.county.present?,
        organisation.postcode.present?,
        organisation.org_type.present?,
        organisation.legal_signatories.exists?
    ].all?

  end

  def complete_organisation_details_for_pre_application?(organisation)

    [
        organisation.name.present?,
        organisation.line1.present?,
        organisation.townCity.present?,
        organisation.county.present?,
        organisation.postcode.present?,
        organisation.org_type.present?,
    ].all?

  end

  # Checks for the presence of an organisation associated to a user
  # and creates one if none exists
  #
  # @param [User] user An instance of User
  def create_organisation_if_none_exists(user)

    # rubocop:disable Style/GuardClause
    unless user.organisations.any?

      logger.info "No organisation found for user ID: #{user.id}"

      create_organisation(user)

    else

      user.organisations.first

    end
    # rubocop:enable Style/GuardClause

  end

  # Creates an organisation and links this to the current_user
  #
  # @param [User] user An instance of User
  def create_organisation(user)

    organisation = user.organisations.create

    logger.info "Successfully created organisation ID: #{organisation.id}"

    organisation

  end

end
