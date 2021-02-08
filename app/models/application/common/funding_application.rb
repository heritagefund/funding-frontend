class FundingApplication < ApplicationRecord

  has_many :addresses, through: :funding_application_addresses

  has_one :project
  has_one :payment_details
  belongs_to :organisation, optional: true

  has_many :funding_applications_people, inverse_of: :funding_application
  has_many :people, through: :funding_applications_people

  has_many :funding_applications_dclrtns, inverse_of: :funding_application
  has_many :declarations, through: :funding_applications_dclrtns

  has_many :funding_applications_pay_reqs, inverse_of: :funding_application
  has_many :payment_requests, through: :funding_applications_pay_reqs

  accepts_nested_attributes_for :organisation, :people, :declarations

  attr_accessor :validate_people
  attr_accessor :validate_declarations

  attr_accessor :payment_still_details_question

  validates_associated :organisation
  validates_associated :people if :validate_people
  validates_associated :declarations, if: :validate_declarations?

  def validate_people?
      validate_people == true
  end

  def validate_declarations?
      validate_declarations == true
  end

  private

  # Method to build an array of specified values from an 
  # ActiveRecord::Collection.
  #
  # @param [ActiveRecord::Collection] active_record_collection An instance of
  #                                                            ActiveRecord::Collection
  # @param [String]                   item_key                 A reference to an item key
  def active_record_collection_to_array(active_record_collection, item_key)
      temp_array = []

      active_record_collection.each do |active_record_item|
          temp_array.append(active_record_item[item_key])
      end

      return {results: temp_array}
  end

  # Method to initialise instance variables containing the response to each 
  # declaration question. question_response will be the applicants response.
  #
  # @param [ActiveRecord::Collection] active_record_collection An instance of
  #                                                            ActiveRecord::Collection
  def get_declarations(active_record_collection)

    active_record_collection.each do |active_record_item|

      question_response = active_record_item.json['question_response']

      case active_record_item.declaration_type
        when 'agreed_to_terms'
          @declaration_agreed_to_terms = question_response ? 
            {results: [question_response]} : {results: [""]}
        when 'data_protection_and_research'
          @declaration_data_protection_and_research = question_response ? 
            {results: [question_response]} : {results: [""]}
        when 'contact'
          @declaration_contact = question_response ? 
            {results: [question_response]} : {results: [""]}
        when 'confirmation'
          @declaration_confirmation = question_response ? 
            {results: [question_response]} : {results: [""]}
        when 'form_feedback'
          @declaration_form_feedback = question_response
        when 'data_and_foi'
          @declaration_data_and_foi = question_response
      end

    end

  end

end

