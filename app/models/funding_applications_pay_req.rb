class FundingApplicationsPayReq < ApplicationRecord
    belongs_to :funding_application
    belongs_to :payment_request
  end
  