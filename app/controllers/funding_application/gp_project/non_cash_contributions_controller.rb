class FundingApplication::GpProject::NonCashContributionsController < ApplicationController
  include FundingApplicationContext, ObjectErrorsLogger

  # This method is used to control navigational flow after a user
  # has submitted the 'Are you getting any non-cash contributions?' form,
  # redirecting based on @funding_application.project.non_cash_contributions_question value, and
  # re-rendering :question if unsuccessful
  def question_update

    logger.info "Updating non-cash contributions question for project ID: " \
                "#{@funding_application.project.id}"

    @funding_application.project.validate_non_cash_contributions_question = true

    @funding_application.project.update(question_params)

    if @funding_application.project.valid?

      logger.info "Finished updating non-cash contributions question for " \
                  "project ID: #{@funding_application.project.id}"

      if @funding_application.project.non_cash_contributions_question == "true"

        redirect_to :funding_application_gp_project_non_cash_contributions

      else

        redirect_to :funding_application_gp_project_volunteers

      end

    else

      logger.info "Validation failed when attempting to update non-cash " \
                  "contributions question for project ID: #{@funding_application.project.id}"

      log_errors(@funding_application.project)

      render :question

    end

  end

  # This method adds a non-cash contribution to a project, redirecting back to
  # :funding_application_gp_project_non_cash_contributions if successful and
  # re-rendering :show method if unsuccessful
  def update

    # Empty flash values to ensure that we don't redisplay them unnecessarily
    flash[:description] = ""
    flash[:amount] = ""

    logger.info "Adding non-cash contribution for project ID: #{@funding_application.project.id}"

    @funding_application.project.validate_non_cash_contributions = true

    @funding_application.project.update(project_params)

    if @funding_application.project.valid?

      logger.info "Successfully added non-cash contribution for project ID: " \
                  "#{@funding_application.project.id}"

      redirect_to :funding_application_gp_project_non_cash_contributions

    else

      logger.info "Validation failed when attempting to add a non-cash " \
                  "contribution for project ID: #{@funding_application.project.id}"

      log_errors(@funding_application.project)

      # Store flash values to display them again when re-rendering the page
      flash[:description] =
          params['project']['non_cash_contributions_attributes']['0']['description']
      flash[:amount] =
          params['project']['non_cash_contributions_attributes']['0']['amount']

      render :show

    end

  end

  # This method deletes a project non-cash contribution, redirecting back to
  # :funding_application_gp_project_non_cash_contributions once completed.
  # If no non-cash contribution is found, then an ActiveRecord::RecordNotFound
  # exception is raised
  def delete

    logger.info "User has selected to delete non-cash contribution ID: " \
                 "#{params[:non_cash_contribution_id]} from project ID: " \
                 "#{@funding_application.project.id}"

    non_cash_contribution =
        @funding_application.project.non_cash_contributions.find(params[:non_cash_contribution_id])

    logger.info "Deleting non-cash contribution ID: #{non_cash_contribution.id}"

    non_cash_contribution.destroy

    logger.debug "Finished deleting non-cash contribution ID: " \
                 "#{non_cash_contribution.id}"

    redirect_to :funding_application_gp_project_non_cash_contributions

  end

  private

  def question_params

    params.fetch(:project, {}).permit(:non_cash_contributions_question)

  end

  def project_params
    params.require(:project).permit(
        non_cash_contributions_attributes: [
            :description,
            :amount
        ]
    )
  end

end
