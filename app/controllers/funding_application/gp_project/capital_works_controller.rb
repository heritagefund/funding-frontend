class FundingApplication::GpProject::CapitalWorksController < ApplicationController
  include FundingApplicationContext, ObjectErrorsLogger

  # This method is used to set the @has_file_upload instance variable before
  # rendering the :show template. This is used within the
  # _direct_file_upload_hooks partial
  def show
    @has_file_upload = true
  end

  # This method updates the capital_work and capital_work_file attributes of a
  # project, redirecting to :three_to_ten_k_project_do_you_need_permission if
  # successful and re-rendering :show method if unsuccessful
  def update
    logger.info "Updating capital_work for project ID: #{@funding_application.project.id}"

    @funding_application.project.validate_capital_work = true

    @funding_application.project.update(project_params)

    if @funding_application.project.valid?

      logger.info "Finished updating capital_work for project ID: " \
                   "#{@funding_application.project.id}"

      # Redirect the user back to the same page if they were uploading a
      # capital work file - this is so that we can display the file back to
      # the user so they can check that they have uploaded the correct file
      
      if params[:project][:capital_work_file].present?
        redirect_to :funding_application_gp_project_capital_works
      else
        redirect_to :funding_application_gp_project_do_you_need_permission
      end

    else

      logger.info "Validation failed when attempting to update capital_work " \
                  "for project ID: #{@funding_application.project.id}"

      log_errors(@funding_application.project)

      render :show

    end

  end

  private

  def project_params

    params.fetch(:project, {}).permit(:capital_work, :capital_work_file)

  end

end
