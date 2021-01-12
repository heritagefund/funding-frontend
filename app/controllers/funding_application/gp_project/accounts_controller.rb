class FundingApplication::GpProject::AccountsController < ApplicationController
  include FundingApplicationContext, ObjectErrorsLogger

  # This method is used to set the @has_file_upload instance variable before
  # rendering the :show template. This is used within the
  # _direct_file_upload_hooks partial
  def show
    @has_file_upload = true
  end

  def update

    logger.info "Updating accounts_files for project ID: #{@funding_application.project.id}"

    @funding_application.project.validate_accounts_files = true

    @funding_application.project.update(project_params)

    if @funding_application.project.valid?

      logger.info "Finished updating accounts_files for project ID: " \
                  "#{@funding_application.project.id}"

      redirect_to :funding_application_gp_project_accounts

    else

      logger.info "Validation failed when attempting to update " \
                  "accounts_files for project ID: #{@funding_application.project.id}"

      log_errors(@funding_application.project)

      render :show

    end

  end

  private

  def project_params

    params.fetch(:project, {}).permit(:accounts_files => [])

  end

end
