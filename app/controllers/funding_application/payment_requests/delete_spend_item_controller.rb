class FundingApplication::PaymentRequests::DeleteSpendItemController < ApplicationController
  include FundingApplicationContext
  include ObjectErrorsLogger
  include PaymentRequestContext

  def show
    @spend = Spend.find_by_id(params[:spend_id])
  end

  def delete

    @spend = Spend.find_by_id(params[:spend_id])
    payment_requests_spend = PaymentRequestsSpend.find_by(spend_id: params[:spend_id])

    logger.info("Attempting to delete spend ID: #{@spend.id}")

    # Encrypt description as this will be stored in the session and could
    # contain sensitive information
    encrypted_description = encryptor.encrypt_and_sign(@spend.description)

    session[:deleted_spend] = {
      description: encrypted_description,
      cost_type_id: @spend.cost_type_id,
      date_of_spend: @spend.date_of_spend.strftime('%d/%m/%Y'),
      net_amount: @spend.net_amount,
      vat_amount: @spend.vat_amount,
      gross_amount: @spend.gross_amount,
      evidence_of_spend_filename: @spend.evidence_of_spend_file.filename
    }

    payment_requests_spend.delete
    @spend.delete

    redirect_to(:funding_application_payment_request_spend_item_deleted)

  end

  private

    # Returns an encryptor, which is used to encrypt the description
    # of the spend item being deleted, as this might contain sensitive information,
    # which we are storing within a session object to be replayed on the next page
    # (where we no longer have access to the now-deleted Spend object)
    def encryptor

      key = ActiveSupport::KeyGenerator.new(
        Rails.configuration.x.payment_encryption_key
      ).generate_key(
        Rails.configuration.x.payment_encryption_salt,
        ActiveSupport::MessageEncryptor.key_len
      ).freeze

      ActiveSupport::MessageEncryptor.new(key)

    end

end
