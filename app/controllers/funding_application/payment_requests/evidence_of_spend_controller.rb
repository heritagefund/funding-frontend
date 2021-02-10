class FundingApplication::PaymentRequests::EvidenceOfSpendController < ApplicationController
  include FundingApplicationContext
  include ObjectErrorsLogger
  include PaymentRequestContext

  def update

    logger.info("Updating evidence of spend for payment_request ID: #{@payment_request.id}")

    redirect_to(:funding_application_payment_request_confirm_what_you_have_spent)

  end

end
