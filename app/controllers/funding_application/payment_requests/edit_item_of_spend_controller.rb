class FundingApplication::PaymentRequests::EditItemOfSpendController < ApplicationController
  include FundingApplicationContext
  include ObjectErrorsLogger
  include PaymentRequestContext

  def show
    @spend = Spend.find_by_id(params[:spend_id])
  end

  def update
  
    @spend = Spend.find_by_id(params[:spend_id])
  
    logger.info("Attempting to update spend ID: #{@spend.id}")
  
    @spend.validate_cost_type = true
    @spend.validate_description = true
    @spend.validate_net_amount = true
    @spend.validate_vat_amount = true
    @spend.validate_gross_amount = true
    @spend.validate_evidence_of_spend_file = true
    @spend.validate_date = true
  
    if @spend.update(spend_params)

      logger.info("Finished updating evidence of spend ID: #{@spend.id})")

      redirect_to(:funding_application_payment_request_tell_us_what_you_have_spent)

    else

      log_errors(@spend)

      render(:show)

    end

  end
  
  private

  def spend_params

    params.require(:spend)
      .permit(
        :cost_type_id,
        :description,
        :custom_date_of_spend,
        :net_amount,
        :vat_amount,
        :gross_amount,
        :evidence_of_spend_file
      )

  end
  
end
  