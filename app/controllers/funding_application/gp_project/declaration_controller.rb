class FundingApplication::GpProject::DeclarationController < ApplicationController
  include FundingApplicationContext, ObjectErrorsLogger

  # This method updates the confirm_declaration attribute of a gp_project,
  # triggering the ApplicationToSalesforceJob and redirecting to
  # :funding_application_gp_project_application_submitted if successful and
  # re-rendering :show_confirm_declaration method if unsuccessful
  def update_confirm_declaration

    logger.info "Updating confirm_declaration for project ID: #{@funding_application.project.id}"

    @funding_application.project.validate_confirm_declaration = true

    @funding_application.project.update(confirm_declaration_params)

    if @funding_application.project.valid?

      logger.info "Finished updating confirm_declaration for project " \
                  "ID: #{@funding_application.project.id}"

      logger.info "Triggering ApplicationToSalesforceJob for project " \
                  "ID: #{@funding_application.project.id}"

      if Flipper.enabled?(:grant_programme_sff_small)
        ApplicationToSalesforceJob.perform_later(@funding_application.project)
        redirect_to :funding_application_gp_project_application_submitted
      else
        redirect_to :funding_application_gp_project_confirm_declaration
      end

    else

      logger.info "Validation failed when attempting to update " \
                  "confirm_declaration for project ID: #{@funding_application.project.id}"

      log_errors(@funding_application.project)

      render :show_confirm_declaration

    end


  end

  # This method updates the declaration-related attributes of a gp_project,
  # redirecting to :funding_application_gp_project_confirm_declaration if successful and
  # re-rendering :show_declaration method if unsuccessful
  def update_declaration

    logger.info "Updating declaration attributes for project ID: #{@funding_application.project.id}"

    @funding_application.project.validate_is_partnership = true

    if params[:project].present?
      if params[:project][:is_partnership].present?
        @funding_application.project.validate_partnership_details = true if
            params[:project][:is_partnership] == "true"
      end
    end

    @funding_application.project.update(declaration_params)

    if @funding_application.project.valid?

      logger.info "Finished updating declaration attributes for project ID: " \
                   "#{@funding_application.project.id}"

      redirect_to :funding_application_gp_project_confirm_declaration

    else

      logger.info "Validation failed when attempting to update declaration " \
                   "attributes for project ID: #{@funding_application.project.id}"

      log_errors(@funding_application.project)

      render :show_declaration

    end

  end

  private

  def confirm_declaration_params

    params.fetch(:project, {}).permit(
        :confirm_declaration,
        :user_research_declaration
    )

  end

  def declaration_params

    params.require(:project).permit(
        :declaration_reasons_description,
        :keep_informed_declaration,
        :is_partnership,
        :partnership_details
    )

  end

end
