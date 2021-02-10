class PaymentRequestsSpend < ApplicationRecord
  belongs_to :payment_request
  belongs_to :spend
end
