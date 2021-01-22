class PreApplication < ApplicationRecord

  belongs_to :organisation, optional: true
  belongs_to :user

  has_many :pre_applications_dclrtns, inverse_of: :pre_application
  has_many :declarations, through: :pre_applications_dclrtns

  has_one :pa_project_enquiry
  has_one :pa_expression_of_interest

  accepts_nested_attributes_for :organisation, :declarations

  def to_salesforce_json

    if self.pa_project_enquiry.present?

      form_type = 'project_enquiry'

      form_hash = {
        project_enquiry:
          { 
            previous_contact_name: self.pa_project_enquiry.previous_contact_name,
            working_title: self.pa_project_enquiry.working_title,
            heritage_focus: self.pa_project_enquiry.heritage_focus,
            what_project_does: self.pa_project_enquiry.what_project_does,
            programme_outcomes: self.pa_project_enquiry.programme_outcomes,
            project_reasons: self.pa_project_enquiry.project_reasons,
            project_participants: self.pa_project_enquiry.project_participants,
            project_timescales: self.pa_project_enquiry.project_timescales,
            project_likely_cost: self.pa_project_enquiry.project_likely_cost,
            potential_funding_amount: self.pa_project_enquiry.potential_funding_amount
          }
      }

    end

    if self.pa_expression_of_interest.present?
      form_type = 'expression_of_interest'

      form_hash = {
        expression_of_interest:
          { 
            previous_contact_name: self.pa_expression_of_interest.previous_contact_name,
            working_title: self.pa_expression_of_interest.working_title,
            heritage_focus: self.pa_expression_of_interest.heritage_focus,
            what_project_does: self.pa_expression_of_interest.what_project_does,
            programme_outcomes: self.pa_expression_of_interest.programme_outcomes,
            project_reasons: self.pa_expression_of_interest.project_reasons,
            project_timescales: self.pa_expression_of_interest.project_timescales,
            overall_cost: self.pa_expression_of_interest.overall_cost,
            potential_funding_amount: self.pa_expression_of_interest.potential_funding_amount,
            likely_submission_description: self.pa_expression_of_interest.likely_submission_description,
          }
      }
    end

    Jbuilder.encode do |json|

      setAddressLines = -> (line1, line2, line3) {
        [line1, line2, line3].compact.join(', ')
      }

      json.ignore_nil!

      json.meta do

        json.set!('preApplicationId', self.id)
        json.set!('form', form_type)
        json.set!('schemaVersion', "v1.x")
        json.set!('startedAt', self.created_at)
        json.set!('username', self.user.email)

      end

      json.pre_application do

        json.form do
          json.merge!(form_hash)
        end

        json.set!('mainContactName', self.user.name)
        json.set!('mainContactDateOfBirth', self.user.date_of_birth)
        json.set!('mainContactEmail', self.user.email)
        json.set!('mainContactPhone', self.user.phone_number)
        json.set!('mainContactCommunicationNeeds', self.user.communication_needs)
        json.set!('mainContactLanguagePreference', self.user.language_preference)
        json.set!('mainContactAgreesToContact', self.user.agrees_to_contact)
        json.set!('mainContactAgreesToUserResearch', self.user.agrees_to_user_research)

        json.mainContactAddress do

          json.line1 setAddressLines.call(
            self.user.line1,
            self.user.line2,
            self.user.line3
          )

          json.townCity self.user.townCity
          json.county self.user.county
          json.postcode self.user.postcode

        end

        json.set!('organisationId', self.user.organisations.first.id)
        json.set!('organisationName', self.user.organisations.first.name)
        json.set!(
          'organisationMission',
          self.user.organisations.first.mission.map!(&:dasherize).map { |m| m == 'lgbt-plus-led' ? 'lgbt+-led' : m }
        )
        json.set!(
          'organisationType',
          get_organisation_type_for_salesforce_json
        )
        json.set!('companyNumber', self.user.organisations.first.company_number)
        json.set!('charityNumber', self.user.organisations.first.charity_number)

        json.organisationAddress do

          json.line1 setAddressLines.call(
            self.user.organisations.first.line1,
            self.user.organisations.first.line2,
            self.user.organisations.first.line3
          )

          json.county self.user.organisations.first.county
          json.townCity self.user.organisations.first.townCity
          json.postcode self.user.organisations.first.postcode

        end

      end

    end

  end

  private
    def get_organisation_type_for_salesforce_json

        formatted_org_type_value = case self.user.organisations.first.org_type
        when 'registered_company', 'community_interest_company'
            'registered-company-or-community-interest-company'
        when 'faith_based_organisation', 'church_organisation'
            'faith-based-or-church-organisation'
        when 'community_group', 'voluntary_group'
            'community-or-voluntary-group'
        when 'individual_private_owner_of_heritage'
            'private-owner-of-heritage'
        when 'other'
            'other-org-type'
        when 'other-public-sector-organisation'
            'other-public-sector-organisation'
        else
            self.user.organisations.first.org_type&.dasherize
        end

        formatted_org_type_value

    end

end
