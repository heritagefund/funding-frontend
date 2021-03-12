require 'rails_helper'

RSpec.describe PreApplication::ExpressionOfInterest::PreviousContactNameController do

  login_user

  let(:pre_application) {
    create(
      :pre_application,
      organisation_id: subject.current_user.organisations.first.id,
      pa_expression_of_interest: create(
        :pa_expression_of_interest
      )
    )
  }

  describe 'GET #show' do

    it 'should redirect if an incomplete organisation is found' do

      get :show,
          params: { pre_application_id: pre_application.id }

      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(
        pre_application_organisation_type_path(
          organisation_id: subject.current_user.organisations.first.id,
          pre_application_id: pre_application.id
        )
      )

    end

    it 'should render the page successfully for a valid pre_application ' \
       'with a complete organisation' do

      subject.current_user.organisations.first.update(
        name: 'Test Organisation',
        line1: '10 Downing Street',
        line2: 'Westminster',
        townCity: 'London',
        county: 'London',
        postcode: 'SW1A 2AA',
        org_type: 1
      )

      get :show,
          params: { pre_application_id: pre_application.id }

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:show)

      expect(
        assigns(:pre_application).pa_expression_of_interest.errors.empty?
      ).to eq(true)

    end

    it 'should redirect to root for an invalid pre_application' do
      get :show, params: { pre_application_id: 'invalid' }
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(:root)
    end

  end

  describe 'PUT #update' do

    it 'should raise a ParameterMissing error if no params are passed' do

      expect {
        put :update, params: {
          pre_application_id: pre_application.id
        }
      }.to(
        raise_error(
          ActionController::ParameterMissing,
          'param is missing or the value is empty: pa_expression_of_interest'
        )
      )

    end

    it 'should raise a ParameterMissing error if an empty ' \
       'pa_expression_of_interest param is passed' do

      expect {
        put :update, params: {
            pre_application_id: pre_application.id,
            pa_expression_of_interest: {}
        }
      }.to raise_error(
               ActionController::ParameterMissing,
               'param is missing or the value is empty: pa_expression_of_interest'
           )

    end

    it 'should successfully progress if an empty previous_contact_name ' \
       'param is passed' do

      put :update, params: {
          pre_application_id: pre_application.id,
          pa_expression_of_interest: { previous_contact_name: '' }
      }

      expect(response).to have_http_status(:redirect)
      expect(response).to(
        redirect_to(
          :pre_application_expression_of_interest_what_will_the_project_do
        )
      )

      expect(
        assigns(:pre_application).pa_expression_of_interest.errors.empty?
      ).to eq(true)
      expect(
        assigns(:pre_application).pa_expression_of_interest.previous_contact_name
      ).to eq(nil)

    end

    it 'should successfully update if a populated previous_contact_name ' \
       'param is passed' do

      put :update, params: {
          pre_application_id: pre_application.id,
          pa_expression_of_interest: {
              previous_contact_name: 'Jean-Luc Picard'
          }
      }

      expect(response).to have_http_status(:redirect)
      expect(response).to(
        redirect_to(
          :pre_application_expression_of_interest_what_will_the_project_do
        )
      )

      expect(
        assigns(:pre_application).pa_expression_of_interest.errors.empty?
      ).to eq(true)
      expect(
        assigns(:pre_application).pa_expression_of_interest.previous_contact_name
      ).to eq('Jean-Luc Picard')

    end

  end

end
