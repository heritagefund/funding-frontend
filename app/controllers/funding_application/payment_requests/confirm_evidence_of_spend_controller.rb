class FundingApplication::PaymentRequests::ConfirmEvidenceOfSpendController < ApplicationController
  include FundingApplicationContext
  include ObjectErrorsLogger
  include PaymentRequestContext
  include PaymentDetailsAndRequestHelper

  def show

    @agreed_project_costs = retrieve_agreed_project_costs(@funding_application)
    @agreed_project_costs_total = calculate_agreed_project_costs_total(@agreed_project_costs)

  end

  def update

    logger.info("Submitting payment_request ID: #{@payment_request.id}")

  end

end
