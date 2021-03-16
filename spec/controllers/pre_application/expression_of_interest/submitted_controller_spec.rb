require 'rails_helper'

RSpec.describe PreApplication::ExpressionOfInterest::SubmittedController do

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
        assigns(:pre_application).pa_expression_of_interest.errors.size
      ).to eq(0)

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
          'param is missing or the value is empty: user'
        )
      )

    end

    it 'should raise a ParameterMissing error if an empty ' \
      'user param is passed' do

      expect {
        put :update, params: {
          pre_application_id: pre_application.id,
          user: {}
        }
      }.to raise_error(
        ActionController::ParameterMissing,
        'param is missing or the value is empty: user'
      )

    end

    it 'should re-render the page if a validation error occurs' do

      allow(controller).to receive(:send_pre_application_user_preferences_to_salesforce).and_return('test')

      # Mock user.update to return false, mimicking a validation error
      allow(subject.current_user).to receive(:update).with(any_args).and_return(false)

      expect(subject).to(
        receive(:log_errors).with(subject.current_user)
      )

      put :update, params: {
        pre_application_id: pre_application.id,
        user: { agrees_to_contact: 'test' }
      }

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:show)

    end

    it 'should successfully update if only agrees_to_contact param is passed' do

      allow(controller).to receive(:send_pre_application_user_preferences_to_salesforce).and_return('test')

      mock_flash = double()

      expect(mock_flash).to receive(:[]=).with(:user_preferences_success, true).once
      expect(mock_flash).to receive(:[]=).with(:user_preferences_success, nil).once

      expect(controller).to receive(:flash).and_return(mock_flash).twice

      put :update, params: {
        pre_application_id: pre_application.id,
        user: { agrees_to_contact: true }
      }

      expect(subject.current_user.errors.size).to eq(0)

      expect(subject.request.flash[:user_preferences_success]).to eq(nil)

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:show)

      expect(subject.current_user.agrees_to_contact).to eq(true)
      expect(subject.current_user.agrees_to_user_research).to eq(nil)

    end

    it 'should successfully update if only agrees_to_user_research param is passed' do

      allow(controller).to receive(:send_pre_application_user_preferences_to_salesforce).and_return('test')

      mock_flash = double()

      expect(mock_flash).to receive(:[]=).with(:user_preferences_success, true).once
      expect(mock_flash).to receive(:[]=).with(:user_preferences_success, nil).once

      expect(controller).to receive(:flash).and_return(mock_flash).twice

      put :update, params: {
        pre_application_id: pre_application.id,
        user: { agrees_to_user_research: true }
      }

      expect(subject.current_user.errors.size).to eq(0)

      expect(subject.request.flash[:user_preferences_success]).to eq(nil)

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:show)

      expect(subject.current_user.agrees_to_contact).to eq(nil)
      expect(subject.current_user.agrees_to_user_research).to eq(true)

    end

    it 'should successfully update if true/false params are passed' do

      allow(controller).to receive(:send_pre_application_user_preferences_to_salesforce).and_return('test')

      mock_flash = double()

      expect(mock_flash).to receive(:[]=).with(:user_preferences_success, true).once
      expect(mock_flash).to receive(:[]=).with(:user_preferences_success, nil).once

      expect(controller).to receive(:flash).and_return(mock_flash).twice

      put :update, params: {
        pre_application_id: pre_application.id,
        user: { agrees_to_contact: true, agrees_to_user_research: false }
      }

      expect(subject.current_user.errors.size).to eq(0)

      expect(subject.request.flash[:user_preferences_success]).to eq(nil)

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:show)

      expect(subject.current_user.agrees_to_contact).to eq(true)
      expect(subject.current_user.agrees_to_user_research).to eq(false)

    end

    it 'should successfully update if false/true params are passed' do

      allow(controller).to receive(:send_pre_application_user_preferences_to_salesforce).and_return('test')

      mock_flash = double()

      expect(mock_flash).to receive(:[]=).with(:user_preferences_success, true).once
      expect(mock_flash).to receive(:[]=).with(:user_preferences_success, nil).once

      expect(controller).to receive(:flash).and_return(mock_flash).twice

      put :update, params: {
        pre_application_id: pre_application.id,
        user: { agrees_to_contact: false, agrees_to_user_research: true }
      }

      expect(subject.current_user.errors.size).to eq(0)

      expect(subject.request.flash[:user_preferences_success]).to eq(nil)

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:show)

      expect(subject.current_user.agrees_to_contact).to eq(false)
      expect(subject.current_user.agrees_to_user_research).to eq(true)

    end

  end

end
