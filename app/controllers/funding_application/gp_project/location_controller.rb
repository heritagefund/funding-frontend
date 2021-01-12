class FundingApplication::GpProject::LocationController < ApplicationController
  include FundingApplicationContext

  def update

    @funding_application.project.validate_same_location = true

    @funding_application.project.update(project_params)

    if @funding_application.project.valid?

      if @funding_application.project.same_location == "yes"

        logger.debug "Same location as organisation selected for project ID: #{@funding_application.project.id}"

        add_project_address_fields

        @funding_application.project.save

        logger.debug "Finished updating location for project ID: #{@funding_application.project.id}"

        redirect_to :funding_application_gp_project_description

      else

        logger.debug "Different location to organisation selected for project ID: #{@funding_application.project.id}"

        redirect_to postcode_path 'project', @funding_application.project.id

      end

    else

      render :show

    end

  end

  private

  def project_params

    params.fetch(:project, {}).permit(:same_location, :line1, :line2, :line3, :townCity, :county, :postcode)

  end

  # Replicates address data from the organisation model linked to the current user
  # into the project model address fields
  def add_project_address_fields

    logger.debug "Setting project address fields for project ID: #{@funding_application.project.id}"

    @organisation = current_user.organisations.first

    @funding_application.project.line1 = @organisation.line1
    @funding_application.project.line2 = @organisation.line2
    @funding_application.project.line3 = @organisation.line3
    @funding_application.project.townCity = @organisation.townCity
    @funding_application.project.county = @organisation.county
    @funding_application.project.postcode = @organisation.postcode

    logger.debug "Finished setting project address fields for project ID: #{@funding_application.project.id}"

  end

end
