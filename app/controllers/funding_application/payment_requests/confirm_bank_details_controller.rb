class FundingApplication::PaymentRequests::ConfirmBankDetailsController < ApplicationController
    include FundingApplicationContext
    include ObjectErrorsLogger
    include PaymentDetailsAndRequestHelper
    include PaymentRequestContext

  def update

    logger.info "Updating evidence_file for payment_details ID: " \
                "#{@funding_application.payment_details.id}"

    @funding_application.payment_details.update(payment_details_params)

    @funding_application.payment_details.validate_evidence_file = true

    if @funding_application.payment_details.valid?

      logger.info "Finished updating payments_details for ID: " \
                  "#{@funding_application.payment_details.id}"

      redirect_to :funding_application_payment_request_confirm_bank_details
      
    else

      logger.info "Validation failed when attempting to update " \
                  "payments_details for ID: #{@funding_application.payment_details.id}"

      log_errors(@funding_application.payment_details)

      render :show

    end

  end

  # Method responsible for validating existence of payment details evidence file
  # before redirecting to the next page in the journey
  def save_and_continue

    logger.info 'Navigating past payment details confirmation screen '
                "for ID: #{@funding_application.payment_details.id}"

    @funding_application.payment_details.validate_evidence_file = true

    if @funding_application.payment_details.valid?

      logger.info 'Successfully validated payment details evidence file when '
                  'navigating past payment details confirmation screen for '
                  "ID: #{@funding_application.payment_details.id}"

      orchestrate_redirect_or_submission(@funding_application, @payment_request)

    else

      logger.info 'Validation failed when attempting to navigate past '
                  "payment details confirmation screen for ID: #{@funding_application.payment_details.id}"

      log_errors(@funding_application.payment_details)

      render :show

    end

  end

  def payment_details_params

    params.fetch(:payment_details, {}).permit(:evidence_file)

  end

end
