require 'rails_helper'

RSpec.describe PreApplication::ExpressionOfInterest::CheckAnswersController do

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

      expect(assigns(:organisation)).to eq(subject.current_user.organisations.first)

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

    it 'should successfully call send_pre_application_to_salesforce ' \
      'before redirecting' do

      expect(controller).to receive(:send_pre_application_to_salesforce).once.with(
        pre_application,
        subject.current_user,
        subject.current_user.organisations.first
      )

      put :update,
          params: { pre_application_id: pre_application.id }

      expect(response).to have_http_status(:redirect)
      expect(response).to(
        redirect_to(
          :pre_application_expression_of_interest_submitted
        )
      )

    end

  end

end
