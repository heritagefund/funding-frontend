# Controller concern used to set the @payment_request
# instance variable
module PaymentRequestContext
  extend ActiveSupport::Concern
  included do
    # This module is included alongside other Context modules
    # which causes an issue with :authenticate_user! being
    # run twice when no user is signed in. To remedy this,
    # we only run :authenticate_user! when a user is signed
    # in.
    before_action :authenticate_user! unless :user_signed_in?
    before_action :set_payment_request
  end

  # This method retrieves a PaymentRequest object based on the id
  # found in the URL parameters and the current authenticated
  # user's id, setting it as an instance variable for use in
  # payment request-related controllers.
  #
  # If no PaymentRequest object matching the parameters is found,
  # then the user is redirected to the applications dashboard.
  def set_payment_request

    @payment_request = PaymentRequest.find_by(
      id: params[:payment_request_id]
    )

    unless @payment_request.present?

      logger.error("User redirected to root, error in payment_request_context.rb")

      redirect_to :authenticated_root

    end

  end

end
