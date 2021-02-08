class FundingApplication::PaymentRequests::ReviewSpendController < ApplicationController
  include FundingApplicationContext
  include ObjectErrorsLogger
  include PaymentDetailsAndRequestHelper

  def show

    @agreed_project_costs = retrieve_agreed_project_costs(@funding_application)
    @agreed_project_costs_total = calculate_agreed_project_costs_total(@agreed_project_costs)

  end

end
