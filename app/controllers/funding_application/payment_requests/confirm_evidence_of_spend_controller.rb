class FundingApplication::PaymentRequests::ConfirmEvidenceOfSpendController < ApplicationController
  include FundingApplicationContext
  include ObjectErrorsLogger
  include PaymentRequestContext
  include PaymentDetailsAndRequestHelper

  def show

    @agreed_project_costs = retrieve_agreed_project_costs(@funding_application)
    @agreed_project_costs_total = calculate_agreed_project_costs_total(@agreed_project_costs)

    # It's possible that we've retrieved agreed costs from Salesforce that a user
    # has yet to evidence with spend items
    @agreed_project_costs_not_yet_evidenced = @agreed_project_costs.select { |apc|
      !CostType.find(
        @payment_request.spends.pluck(:cost_type_id).uniq
      ).pluck(:name)
        .include?(apc.Cost_heading__c)
    }

  end

  def update

    logger.info("Submitting payment_request ID: #{@payment_request.id}")

  end

end
