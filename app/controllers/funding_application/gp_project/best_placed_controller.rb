class FundingApplication::GpProject::BestPlacedController < ApplicationController
  include FundingApplicationContext, ObjectErrorsLogger

  # This method updates the best_placed_description attribute of a project,
  # redirecting to :three_to_ten_k_project_how_will_your_project_involve_people
  # if successful and re-rendering :show method if unsuccessful
  def update

    logger.info "Updating best_placed_description for project ID: " \
                 "#{@funding_application.project.id}"

    @funding_application.project.validate_best_placed_description = true

    @funding_application.project.update(project_params)

    if @funding_application.project.valid?

      logger.info "Finished updating best_placed_description for project " \
                   "ID: #{@funding_application.project.id}"

      redirect_to :funding_application_gp_project_how_will_your_project_involve_people

    else

      logger.info "Validation failed when attempting to update " \
                  "best_placed_description for project ID: #{@funding_application.project.id}"

      log_errors(@funding_application.project)

      render :show

    end

  end

  private

  def project_params

    params.fetch(:project, {}).permit(:best_placed_description)

  end
  
end
