class FundingApplication::GpProject::HeritageController < ApplicationController
  include FundingApplicationContext, ObjectErrorsLogger

  # This method updates the heritage_description attribute of a project,
  # redirecting to :three_to_ten_k_project_why_is_your_organisation_best_placed
  # if successful and re-rendering :show method if unsuccessful
  def update

    logger.info "Updating heritage_description for project ID: #{@funding_application.project.id}"

    @funding_application.project.validate_heritage_description = true

    @funding_application.project.update(project_params)

    if @funding_application.project.valid?

      logger.debug "Finished updating heritage_description for project " \
                   "ID: #{@funding_application.project.id}"

      redirect_to :funding_application_gp_project_why_is_your_organisation_best_placed

    else

      logger.info "Validation failed when attempting to update " \
                  "heritage_description for project ID: #{@funding_application.project.id}"

      log_errors(@funding_application.project)

      render :show

    end

  end

  private

  def project_params

    params.fetch(:project, {}).permit(:heritage_description)

  end

end
