class Spend < ApplicationRecord
  include ActiveModel::Validations, GenericValidator

  belongs_to :cost_type

  has_many :payment_requests_spends, inverse_of: :spend
  has_many :payment_requests, through: :payment_requests_spends

  attr_accessor :validate_item_of_spend

  attr_accessor :validate_cost_type
  attr_accessor :validate_description
  attr_accessor :validate_net_amount
  attr_accessor :validate_vat_amount
  attr_accessor :validate_gross_amount
  attr_accessor :validate_evidence_of_spend_file
  attr_accessor :validate_evidence_of_spend_file
  attr_accessor :validate_date

  attr_accessor :custom_date_of_spend

  has_one_attached :evidence_of_spend_file

  validates :cost_type, presence: true, if: :validate_cost_type?
  validates :description, presence: true, if: :validate_description?

  validates :net_amount, numericality: {
    greater_than: 0,
    less_than: 2147483648
  }, if: :validate_net_amount?

  validates :vat_amount, numericality: {
    greater_than: 0,
    less_than: 2147483648
  }, if: :validate_vat_amount?

  validates :gross_amount, numericality: {
    greater_than: 0,
    less_than: 2147483648
  }, if: :validate_gross_amount?

  validate do

    if validate_cost_type

      unless (CostType.first.id..CostType.last.id).member?(self.cost_type_id)
        self.errors.add(
          'cost_type',
          'Enter a valid spend type'
        )
      end

    end

    validate_length(
      :description,
      500,
      I18n.t('activerecord.errors.models.spend.attributes.description.too_long', word_count: 500)
    ) if validate_description?

    if validate_date?

      unless self.custom_date_of_spend.present?

        self.errors.add(
          'custom_date_of_spend',
          'Enter a date'
        )

      else

        begin

          unless Date.valid_date?(
            self.custom_date_of_spend[1],
            self.custom_date_of_spend[2],
            self.custom_date_of_spend[3]
          )
    
            self.errors.add(
                'custom_date_of_spend',
                'Date must be a valid date'
            )
    
          else
    
            self.date_of_spend = self.custom_date_of_spend
    
          end

        # Rescuing TypeError, as we cannot convert from nil to an integer (in order to validate date)
        # Rescuing NoMethodError, as Date.valid_date cannot operate on a nil value in first param
        rescue TypeError, NoMethodError => e
          self.errors.add(
            'custom_date_of_spend',
            'Date must be a valid date'
          )
        end

      end

    end

  end

  validate do
    validate_file_attached(
        :evidence_of_spend_file,
        I18n.t("activerecord.errors.models.spend.attributes.evidence_of_spend_file.inclusion")
    ) if validate_evidence_of_spend_file?
  end

  def validate_cost_type?
    validate_cost_type == true
  end

  def validate_description?
    validate_description == true
  end

  def validate_net_amount?
    validate_net_amount ==true
  end
  
  def validate_vat_amount?
    validate_net_amount ==true
  end

  def validate_gross_amount?
    validate_net_amount ==true
  end     

  def validate_evidence_of_spend_file?
    validate_evidence_of_spend_file == true
  end

  def validate_date?
    validate_date == true
  end

end
