class PaymentDetails < ApplicationRecord
  include ActiveModel::Validations, GenericValidator
  
  belongs_to :funding_application

  attr_accessor :validate_account_name_presence
  attr_accessor :validate_account_number_presence
  attr_accessor :validate_account_number_format
  attr_accessor :validate_sort_code_presence
  attr_accessor :validate_sort_code_format
  attr_accessor :encrypt_account_name
  attr_accessor :validate_building_society_roll_number_format
  attr_accessor :validate_payment_reference_format
  attr_accessor :validate_evidence_file

  has_one_attached :evidence_file

  validates :account_name, presence: true, if: :validate_account_name_presence?
  validates :account_number, presence: true, if: :validate_account_number_presence?
  validates :sort_code, presence: true, if: :validate_sort_code_presence?

  validate :validate_encrypt_and_set_account_number_format, if: :validate_account_number_format?
  validate :validate_encrypt_and_set_sort_code_format, if: :validate_sort_code_format?
  validate :encrypt_and_set_account_name, if: :encrypt_account_name?
  validate :validate_encrypt_and_set_building_society_roll_number_format, if: :validate_building_society_roll_number_format?
  validate :validate_encrypt_and_set_payment_reference, if: :validate_payment_reference_format?

  # Runs when the payment details model is lazy loaded in.
  KEY = ActiveSupport::KeyGenerator.new(
    Rails.configuration.x.payment_encryption_key
  ).generate_key(
    Rails.configuration.x.payment_encryption_salt,
    ActiveSupport::MessageEncryptor.key_len
  ).freeze

  # Returns an encryptor using the KEY constant.
  # Encryptor is used to encrypt payment information for storing on the database,
  # and decrypt it for rendering within the payment forms.
  #
  # @param [KEY] The KEY constant which is initialised when the model is 1st used.
  def encryptor
    ActiveSupport::MessageEncryptor.new(KEY)
  end

  def validate_evidence_file?
    validate_evidence_file == true
  end

  def validate_account_name_presence?
    validate_account_name_presence == true
  end

  def validate_account_number_presence?
    validate_account_number_presence == true
  end

  def validate_account_number_format?
    validate_account_number_format == true
  end

  def validate_sort_code_presence?
    validate_sort_code_presence == true
  end

  def validate_sort_code_format?
    validate_sort_code_format == true
  end

  def validate_building_society_roll_number_format?
    validate_building_society_roll_number_format == true
  end

  def validate_payment_reference_format?
    validate_payment_reference_format == true
  end

  def encrypt_account_name?
    encrypt_account_name == true
  end

  validate do
    validate_file_attached(
        :evidence_file,
        I18n.t("activerecord.errors.models.payment_details.attributes.evidence_file.inclusion")
    ) if validate_evidence_file?
  end

  # Method to validate that an entered sort code (once stripped of spurious non-numeric characters)
  # is the correct length. If length is correct, then the sort_code attribute is updated to no
  # longer contain non-numeric characters, otherwise the errors hash is populated.
  # If validation passes, turn off validation and write the encrypted value. This is because validation 
  # will fail as the encrypted value will not meet the validation rules.
  def validate_encrypt_and_set_sort_code_format

    if self.sort_code.present?

      tmp = self.sort_code.gsub(/\D/,'')

      if tmp.length != 6 
        errors.add(:sort_code,
          I18n.t("activerecord.errors.models.payment_details.attributes.sort_code.invalid_format"))        
      else
        self.validate_sort_code_format = false
        self.sort_code = encryptor.encrypt_and_sign(tmp)
      end
    end

  end

  # Method to validate that an entered account number (once stripped of spurious non-numeric characters)
  # is the correct length. If length is correct, then the account_number attribute is updated to no
  # longer contain non-numeric characters, otherwise the errors hash is populated.
  # If validation passes, turn off validation and write the encrypted value. his is because validation 
  # will fail as the encrypted value will not meet the validation rules.
  def validate_encrypt_and_set_account_number_format
    if self.account_number.present?

      tmp = self.account_number.gsub(/\D/, '')

      if tmp.length < 6 || tmp.length > 8
        errors.add(:account_number,
          I18n.t("activerecord.errors.models.payment_details.attributes.account_number.invalid_format"))    
      else
        self.validate_account_number_format = false
        self.account_number = encryptor.encrypt_and_sign(tmp)
      end
    end
  end

  def validate_encrypt_and_set_building_society_roll_number_format

    if self.building_society_roll_number.present?

      tmp = self.building_society_roll_number.gsub(/\D/, '')

      if tmp.length < 1 || tmp.length > 18

        errors.add(
          :building_society_roll_number,
          I18n.t('activerecord.errors.models.payment_details.attributes.building_society_roll_number.invalid_format')
        )

      else

        self.validate_building_society_roll_number_format = false
        self.building_society_roll_number = encryptor.encrypt_and_sign(tmp)

      end

    end

  end

  def validate_encrypt_and_set_payment_reference

    if self.payment_reference.present?

      tmp = self.payment_reference

      # TODO: Validate here
      if tmp.length > 18

        errors.add(
          :payment_reference,
          I18n.t('activerecord.errors.models.payment_details.attributes.payment_reference.too_long')
        )

      elsif tmp.match(/\A\p{Alnum}+\z/) == nil

        errors.add(
          :payment_reference,
          I18n.t('activerecord.errors.models.payment_details.attributes.payment_reference.invalid_format')
        )

      else

        self.validate_payment_reference_format = false
        self.payment_reference = encryptor.encrypt_and_sign(tmp)

      end

    end

  end

  # Encrypts the account name, if it is present.
  # Set encryption toggle to false, before encrypting.  This prevents 
  # encryption happening more that once until the controller's show function runs again.
  # For exmaple when re-rendering owing to an error on another field.
  def encrypt_and_set_account_name
    if self.account_name.present?
      self.encrypt_account_name = false
      tmp = encryptor.encrypt_and_sign(self.account_name)
      self.account_name = tmp
    end
  end

  def decrypt_account_name
    self.account_name.present? ? encryptor.decrypt_and_verify(self.account_name) : ''
  end

  # Decrypts an encrypted account number.  Or returns a blank string or in memory value.
  # If the account_number is present, proceed.  If not, return blank string.
  # If payment details contain errors within this field, display the in memory value
  # rather than the encrypted value on the database
  def decrypt_account_number
    if self.account_number.present?
      unless self.errors[:account_number].present?
        encryptor.decrypt_and_verify(self.account_number)
      else
        self.account_number
      end
    else
      ''
    end
  end

  # Decrypts an encrypted sort code.  Or returns a blank string or in memory value.
  # If the sort_code is present, proceed.  If not, return blank string.
  # If payment details contain errors within this field, display the in memory value
  # rather than the encrypted value on the database
  def decrypt_sort_code
    if self.sort_code.present?
      unless self.errors[:sort_code].present?
        encryptor.decrypt_and_verify(self.sort_code)
      else
        self.sort_code
      end
    else
      ''
    end
  end

  # Decrypts an encrypted building society roll number, or returns a blank string or in memory value.
  # If the building_society_roll_number is present, proceed. If not, return blank string.
  # If payment details contain errors within this field, display the in memory value
  # rather than the encrypted value on the database
  def decrypt_building_society_roll_number
    if self.building_society_roll_number.present?
      unless self.errors[:building_society_roll_number].present?
        encryptor.decrypt_and_verify(self.building_society_roll_number)
      else
        self.building_society_roll_number
      end
    else
      ''
    end
  end

  # Decrypts an encrypted payment_reference, or returns a blank string or in memory value.
  # If the payment_reference is present, proceed. If not, return blank string.
  # If payment_details contain errors within this field, display the in memory value
  # rather than the encrypted value on the database
  def decrypt_payment_reference
    if self.payment_reference.present?
      unless self.errors[:payment_reference].present?
        encryptor.decrypt_and_verify(self.payment_reference)
      else
        self.payment_reference
      end
    else
      ''
    end
  end

end