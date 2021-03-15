require 'rails_helper'

RSpec.describe PreApplication::ExpressionOfInterest::WhatProjectDoesController do

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

    it 'should render the page successfully for a valid pre_application' do

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

    it 'should re-render the page if a validation error occurs' do

      put :update, params: {
        pre_application_id: pre_application.id,
        pa_expression_of_interest: { what_project_does: 'word ' * 201 }
      }

      expect(
        assigns(:pre_application).pa_expression_of_interest.errors[:what_project_does]
      ).to include(
        I18n.t(
          'activerecord.errors.models.pa_expression_of_interest.attributes.what_project_does.too_long',
          word_count: 200
        )
      )

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:show)

    end

    it 'should successfully progress if an empty what_project_does ' \
       'param is passed' do

      put :update, params: {
          pre_application_id: pre_application.id,
          pa_expression_of_interest: { what_project_does: '' }
      }

      expect(
        assigns(:pre_application).pa_expression_of_interest.errors.any?
      ).to eq(false)

      expect(response).to have_http_status(:redirect)
      expect(response).to(
        redirect_to(
          :pre_application_expression_of_interest_do_you_have_a_working_title
        )
      )

      expect(
        assigns(:pre_application).pa_expression_of_interest.errors.empty?
      ).to eq(true)
      expect(
        assigns(:pre_application).pa_expression_of_interest.what_project_does
      ).to eq(nil)

    end

    it 'should successfully update if a populated what_project_does ' \
       'param is passed' do

      put :update, params: {
          pre_application_id: pre_application.id,
          pa_expression_of_interest: {
              what_project_does: 'Test value'
          }
      }

      expect(
        assigns(:pre_application).pa_expression_of_interest.errors.any?
      ).to eq(false)

      expect(response).to have_http_status(:redirect)
      expect(response).to(
        redirect_to(
          :pre_application_expression_of_interest_do_you_have_a_working_title
        )
      )

      expect(
        assigns(:pre_application).pa_expression_of_interest.errors.empty?
      ).to eq(true)
      expect(
        assigns(:pre_application).pa_expression_of_interest.what_project_does
      ).to eq('Test value')

    end

  end

end
