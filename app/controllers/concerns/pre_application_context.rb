# Controller concern used to set the @pre_application
# instance variable
module PreApplicationContext
  extend ActiveSupport::Concern
  included do
    # This module is included alongside other Context modules
    # which causes an issue with :authenticate_user! being
    # run twice when no user is signed in. To remedy this,
    # we only run :authenticate_user! when a user is signed
    # in.
    before_action :authenticate_user! unless :user_signed_in?
    before_action :set_pre_application
  end

  # This method retrieves a PreApplication object based on the id
  # found in the URL parameters and the current authenticated
  # user's id, setting it as an instance variable for use in
  # pre application-related controllers.
  #
  # If no PreApplication object matching the parameters is found,
  # then the user is redirected to the applications dashboard.
  def set_pre_application

    @pre_application = PreApplication.find_by(
      id: params[:pre_application_id],
      organisation_id: current_user.organisations.first&.id
    )

    if !@pre_application.present? || (@pre_application.submitted_on.present? &&
        !request.path.include?('/submitted'))

      logger.error('User redirected to root, error in pre_application_context.rb')

      redirect_to :authenticated_root

    else

      # A PreApplication GUID is used to access both project enquiry and expression
      # of interest pre-application journeys. We should ensure that a user is not
      # able to access one type of journey using a PreApplication GUID which has
      # an associated object related to the other type of journey (e.g. using a
      # PreApplication GUID with an associated PaExpressionOfInterest object to
      # access the project enquiry journey)

      if request.path.include?('expression-of-interest')

        unless @pre_application.pa_expression_of_interest.present?

          logger.error(
            'User redirected to root, attempted to access /expression-of-interest ' \
            'URI using PreApplication object with no associated PaExpressionOfInterest'
          )

          redirect_to :authenticated_root

        end

      end

      if request.path.include?('project-enquiry')

        unless @pre_application.pa_project_enquiry.present?

          logger.error(
            'User redirected to root, attempted to access /project-enquiry URI ' \
            'using PreApplication object with no associated PaProjectEnquiry'
          )

          redirect_to :authenticated_root

        end

      end

    end

  end

end
