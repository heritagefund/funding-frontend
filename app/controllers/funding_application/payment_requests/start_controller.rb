class FundingApplication::PaymentRequests::StartController < ApplicationController
  include FundingApplicationContext
  include ObjectErrorsLogger
  include PaymentDetailsAndRequestHelper

  def update

    payment_request = @funding_application.payment_requests.create

    unless @funding_application.payment_details.present?

      redirect_to_enter_bank_details(payment_request)

    else

      redirect_to_are_these_your_bank_details(payment_request)

    end

  end

end