class FundingApplication::GpProject::MatterController < ApplicationController
  include FundingApplicationContext, ObjectErrorsLogger

  def update

    logger.info "Updating matter for project ID: #{@funding_application.project.id}"

    @funding_application.project.validate_matter = true

    @funding_application.project.update(project_params)

    if @funding_application.project.valid?

      logger.info "Finished updating matter for project ID: #{@funding_application.project.id}"

      redirect_to :funding_application_gp_project_your_project_heritage

    else

      logger.info "Validation failed when attempting to update matter for " \
                  "project ID: #{@funding_application.project.id}"

      log_errors(@funding_application.project)

      render :show

    end

  end

  private

  def project_params

    params.fetch(:project, {}).permit(:matter)

  end

end
