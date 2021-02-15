class FundingApplication::PaymentRequests::SubmittedController < ApplicationController
  include FundingApplicationContext
  include ObjectErrorsLogger
  include PaymentDetailsAndRequestHelper
  include PaymentRequestContext

  def show

    grant_award_and_payment_request_percentage = get_grant_award_type(@funding_application)

    @award_type = grant_award_and_payment_request_percentage[:grant_award_type]
    @payment_request_percentage = grant_award_and_payment_request_percentage[:payment_request_percentage]

  end

end
