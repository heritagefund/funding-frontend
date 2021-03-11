class DoesNotMatchOtherSignatoryValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if record == record.organisation.legal_signatories.second && value == record.organisation.legal_signatories.first.email_address
      record.errors.add(attribute, (options[:message] || "must be different to first signatory email address"))
    end
  end
end

class LegalSignatory < ApplicationRecord
  belongs_to :organisation
  self.implicit_order_column = "created_at"

  attr_accessor :validate_name
  attr_accessor :validate_email_address
  attr_accessor :validate_phone_number

  after_validation do
    self.delete if ignore_validation_for_empty_second_signatory?(self)
  end

  validates :name, presence: true,
            unless: lambda {
                |record| ignore_validation_for_empty_second_signatory?(record)
            }
  validates :email_address,
            format: { with: URI::MailTo::EMAIL_REGEXP },
            does_not_match_other_signatory: true,
            unless: lambda {
                |record| ignore_validation_for_empty_second_signatory?(record)
            }
  validates :phone_number,
            presence: true,
            unless: lambda {
                |record| ignore_validation_for_empty_second_signatory?(record)
            }

  # Method used to determine whether a legal signatory should not
  # be validated. We check for this as the first legal signatory is mandatory,
  # whereas the second only needs to be validated if any of the record's
  # attributes have been populated
  def ignore_validation_for_empty_second_signatory?(record)
    record.name.blank? &&
        record.email_address.blank? &&
        record.phone_number.blank? &&
        record == organisation.legal_signatories.second
  end

  def validate_name?
    validate_name == true
  end

  def validate_email_address?
    validate_email_address == true
  end

  def validate_phone_number?
    validate_phone_number == true
  end

end
