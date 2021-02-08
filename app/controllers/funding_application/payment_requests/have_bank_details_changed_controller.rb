class FundingApplication::PaymentRequests::HaveBankDetailsChangedController < ApplicationController
  include FundingApplicationContext
  include ObjectErrorsLogger
  include PaymentDetailsAndRequestHelper
  include PaymentRequestContext

  def update

    # TODO: Change 'payment_still_details_question'to something better here and in the model and view
    if params[:funding_application][:payment_still_details_question] == 'false'

      orchestrate_redirect_or_submission(@funding_application, @payment_request)

    else

      redirect_to_enter_bank_details(@payment_request)

    end

  end

  private

  def question_params

    params.fetch(:funding_application, {}).permit(:payment_still_details_question)

  end

end