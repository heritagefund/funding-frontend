class FundingApplication::GpProject::InvolvementController < ApplicationController
  include FundingApplicationContext, ObjectErrorsLogger

  # This method updates the involvement_description attribute of a project,
  # redirecting to :three_to_ten_k_project_other_outcomes if successful and
  # re-rendering :show method if unsuccessful
  def update

    logger.info "Updating involvement_description for project " \
                "ID: #{@funding_application.project.id}"

    @funding_application.project.validate_involvement_description = true

    @funding_application.project.update(project_params)

    if @funding_application.project.valid?

      logger.info "Finished updating project involvement_description for " \
                  "project ID: #{@funding_application.project.id}"

      redirect_to :funding_application_gp_project_our_other_outcomes

    else

      logger.info "Validation failed when attempting to update " \
                  "involvement_description for project ID: #{@funding_application.project.id}"

      log_errors(@funding_application.project)

      render :show

    end

  end

  private

  def project_params

    params.fetch(:project, {}).permit(:involvement_description)

  end

end
