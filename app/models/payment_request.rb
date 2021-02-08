class PaymentRequest < ApplicationRecord

  has_many :funding_applications_pay_reqs, inverse_of: :payment_request
  has_many :funding_applications, through: :funding_applications_pay_reqs

end