class FundingApplication::PaymentRequests::ConfirmEvidenceOfSpendController < ApplicationController
  include FundingApplicationContext
  include ObjectErrorsLogger
  include PaymentRequestContext
  include PaymentDetailsAndRequestHelper

  def show

    @agreed_project_costs = retrieve_agreed_project_costs(@funding_application)
    @agreed_project_costs_total = calculate_agreed_project_costs_total(@agreed_project_costs)

    # It's possible that we've retrieved agreed costs from Salesforce that a user
    # has yet to evidence with spend items. Here, we are using select to narrow
    # the list of agreed project costs to *only* those which do not have matching
    # spend items in funding-frontend. If Salesforce has returned 'New staff' and
    # 'Professional fees', but funding-frontend only has a spend item with a cost
    # type of 'New staff', then @agreed_project_costs_not_yet_evidenced will contain
    # 'Professional fees'.
    @agreed_project_costs_not_yet_evidenced = @agreed_project_costs.select { |apc|
      !CostType.find(@payment_request.spends.pluck(:cost_type_id).uniq)
        .pluck(:name).include?(apc.Cost_heading__c)
    }

  end

  def update

    logger.info("Submitting payment_request ID: #{@payment_request.id}")

    grant_percentage = retrieve_payment_related_details(@funding_application)[:grant_percentage]
  
    calculate_payment_request_over_100000(@payment_request, grant_percentage)

    logger.info('Redirecting to payment request submitted ')

    redirect_to(:funding_application_payment_request_submitted)

  end

end
