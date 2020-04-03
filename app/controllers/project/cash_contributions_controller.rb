class Project::CashContributionsController < ApplicationController
  include ProjectContext, ObjectErrorsLogger

  # This method is used to set the @has_file_upload instance variable before
  # rendering the :show template. This is used within the
  # _direct_file_upload_hooks partial
  def show
    @has_file_upload = true
  end

  # This method is used to control navigational flow after a user
  # has submitted the 'Are you getting any cash contributions?' form,
  # redirecting based on @project.cash_contributions_question value, and
  # re-rendering :question if unsuccessful
  def question_update

    logger.info "Updating cash contributions question for project ID: " \
                "#{@project.id}"

    @project.validate_cash_contributions_question = true

    @project.update(question_params)

    if @project.valid?

      logger.info "Finished updating cash contributions question for project " \
                  "ID: #{@project.id}"

      if @project.cash_contributions_question == "true"

        redirect_to :three_to_ten_k_project_project_cash_contribution

      else

        redirect_to :three_to_ten_k_project_grant_request_get

      end

    else

      logger.info "Validation failed for cash contributions question for " \
                  "project ID: #{@project.id}"

      log_errors(@project)

      render :question

    end

  end

  # This method adds a cash contribution to a project, redirecting back to
  # :three_to_ten_k_project_project_cash_contribution if successful and
  # re-rendering :show method if unsuccessful
  def update

    logger.info "Adding cash contribution for project ID: #{@project.id}"

    @project.validate_cash_contributions = true

    @project.update(project_params)

    if @project.valid?

      logger.info "Successfully added cash contribution for project ID: " \
                  "#{@project.id}"

      redirect_to :three_to_ten_k_project_project_cash_contribution

    else

      logger.info "Validation failed when attempting to add a cash " \
                  "contribution for project ID: #{@project.id}"

      log_errors(@project)

      render :show

    end

  end

  # This method deletes a project cash contribution, redirecting back to
  # :three_to_ten_k_project_project_cash_contribution once completed.
  # If no cash contribution is found, then an ActiveRecord::RecordNotFound
  # exception is raised
  def delete

    logger.info "User has selected to delete cash contribution ID: " \
                "#{params[:cash_contribution_id]} from project ID: " \
                "#{@project.id}"

    cash_contribution =
        @project.cash_contributions.find(params[:cash_contribution_id])

    logger.info "Deleting cash contribution ID: #{cash_contribution.id}"

    cash_contribution.destroy

    logger.info "Finished deleting cash contribution ID: " \
                "#{cash_contribution.id}"

    redirect_to :three_to_ten_k_project_project_cash_contribution

  end

  private
  def question_params

    unless params[:project].present?
      params.merge!({project: {cash_contributions_question: ""}})
    end

    params.require(:project).permit(:cash_contributions_question)

  end

  def project_params
    params.require(:project).permit(
        cash_contributions_attributes: [
            :description,
            :secured,
            :amount,
            :cash_contribution_evidence_files
        ]
    )
  end

end