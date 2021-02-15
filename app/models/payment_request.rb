class PaymentRequest < ApplicationRecord

  has_many :funding_applications_pay_reqs, inverse_of: :payment_request
  has_many :funding_applications, through: :funding_applications_pay_reqs

  has_many :payment_requests_spends, inverse_of: :payment_request
  has_many :spends, through: :payment_requests_spends

  # Method to convert a PaymentRequest object into JSON format, ready for
  # submission to Salesforce
  #
  # @return [JSON] A JSON representation of a PaymentRequest object
  def to_json

    Jbuilder.encode do |json|

      json.ignore_nil!

      json.meta do

        json.set!('project_id', self.funding_applications.first.project.id)
        json.set!('payment_request_id', self.id)
        json.set!('payment_details_id', self.funding_applications.first.payment_details.id)

      end

      json.bank_details do

        json.set!('account_name', self.funding_applications.first.payment_details.account_name)
        json.set!('account_number', self.funding_applications.first.payment_details.account_number)
        json.set!('sort_code', self.funding_applications.first.payment_details.sort_code)
        json.set!('building_society_roll_number', self.funding_applications.first.payment_details.building_society_roll_number)
        json.set!('payment_reference', self.funding_applications.first.payment_details.payment_reference)

      end

      json.payment_request do

        json.set!('amount_requested', self.amount_requested)

      end

    end

  end

end