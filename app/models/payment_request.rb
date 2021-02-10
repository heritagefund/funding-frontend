class PaymentRequest < ApplicationRecord

  has_many :funding_applications_pay_reqs, inverse_of: :payment_request
  has_many :funding_applications, through: :funding_applications_pay_reqs

  has_many :payment_requests_spends, inverse_of: :payment_request
  has_many :spends, through: :payment_requests_spends

end