class FundingApplication::PaymentRequests::SpendItemDeletedController < ApplicationController
    include FundingApplicationContext
    include ObjectErrorsLogger
    include PaymentRequestContext
  
    def show

      @deleted_spend_item = {
        description: encryptor.decrypt_and_verify(session[:deleted_spend]['description']),
        cost_type: CostType.find_by_id(session[:deleted_spend]['cost_type_id']).name,
        date_of_spend: session[:deleted_spend]['date_of_spend'],
        net_amount: session[:deleted_spend]['net_amount'],
        vat_amount: session[:deleted_spend]['vat_amount'],
        gross_amount: session[:deleted_spend]['gross_amount'],
        evidence_of_spend_filename: session[:deleted_spend]['evidence_of_spend_filename']
      }

    end
  
    # Returns an encryptor, which is used to decrypt the description
    # of the Spend object which has been deleted, which we are storing 
    # within a session object to be replayed on this page
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
  