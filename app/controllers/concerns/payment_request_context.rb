# Controller concern used to set the @payment_request
# instance variable
module PaymentRequestContext
    extend ActiveSupport::Concern
    included do
      before_action :authenticate_user!, :set_payment_request
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
  
