class FundingApplication::GpProject::DifferenceController < ApplicationController
  include FundingApplicationContext, ObjectErrorsLogger

  # This method updates the difference attribute of a project, redirecting to
  # :three_to_ten_k_project_how_does_your_project_matter if successful and
  # re-rendering :show method if unsuccessful
  def update

    logger.info "Updating difference for project ID: #{@funding_application.project.id}"

    @funding_application.project.validate_difference = true

    @funding_application.project.update(project_params)

    if @funding_application.project.valid?

      logger.info "Finished updating difference for project ID: #{@funding_application.project.id}"

      redirect_to :funding_application_gp_project_how_does_your_project_matter

    else

      logger.info "Validation failed when attempting to update difference " \
                  "for project ID: #{@funding_application.project.id}"

      log_errors(@funding_application.project)

      render :show

    end

  end

  private

  def project_params

    params.fetch(:project, {}).permit(:difference)

  end

end
