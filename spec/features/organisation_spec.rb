require 'rails_helper'

RSpec.feature 'Organisation', type: :feature do

  scenario 'Successful creation of an organisation with a single legal ' \
           'signatory' do

    begin

      Flipper[:new_applications_enabled].enable

      user = FactoryBot.create(
          :user,
          name: 'Jane Doe',
          date_of_birth: Date.new,
          line1: 'line 1',
          phone_number: '123',
          postcode: 'W11AA',
          townCity: 'London',
          county: 'London'
      )

      login_as(user, :scope => :user)

      visit '/'
      expect(page).to have_text I18n.t("dashboard.funding_applications.buttons.start")

      click_link_or_button I18n.t("dashboard.funding_applications.buttons.start")
          
      expect(page)
          .to have_text 'What type of organisation will be running your project'

      choose 'Registered charity'
      click_link_or_button 'Save and continue'

      expect(page)
          .to have_text 'What is your company number?'
      expect(page)
          .to have_text 'What is your charity number?'

      fill_in 'organisation[charity_number]', with: '123'
      click_link_or_button 'Save and continue'

      set_address(title_field = 'Organisation name')

      expect(page)
          .to have_text 'Tell us about the mission, or objectives, of your ' \
                      'organisation'

      check 'Female led'
      click_link_or_button 'Save and continue'

      expect(page)
          .to have_text 'Who is your legal signatory?'

      fill_in 'Full name', match: :first, with: 'Jane Doe'
      fill_in 'Email address', match: :first, with: 'test@example.com'
      fill_in 'Phone number', match: :first, with: '123'

      click_link_or_button 'Save and continue'


      expect(page).to have_text('Check your answers')
      expect(page).to have_text('Registered charity')
      expect(page).to have_text('123')
      expect(page).to have_text('test')
      expect(page).to have_text('4 Barons Court Road')
      expect(page).to have_text('London')
      expect(page).to have_text('W14 9DT')
      expect(page).to have_text('Female led')
      expect(page).to have_text('Jane Doe')

      organisation = User.find(user.id).organisations.first
      expect(organisation.org_type).to eq('registered_charity')
      expect(organisation.charity_number).to eq('123')
      expect(organisation.name).to eq('test')
      expect(organisation.line1).to eq('4 Barons Court Road')
      expect(organisation.townCity).to eq('LONDON')
      expect(organisation.county).to eq('London')
      expect(organisation.postcode).to eq('W14 9DT')
      expect(organisation.mission).to include('female_led')
      expect(organisation.legal_signatories.first.name).to eq('Jane Doe')
      expect(organisation.legal_signatories.first.email_address)
          .to eq('test@example.com')
      expect(organisation.legal_signatories.first.phone_number)
          .to eq('123')

    ensure

      Flipper[:new_applications_enabled].disable

    end

  end

  scenario 'Non-selection of an organisation type should return an error' do

    begin

      Flipper[:new_applications_enabled].enable

      user = FactoryBot.create(
          :user,
          name: 'Jane Doe',
          date_of_birth: Date.new,
          line1: 'line 1',
          phone_number: '123',
          postcode: 'W11AA',
          townCity: 'London',
          county: 'London'
      )

      login_as(user, :scope => :user)

      visit '/'
      expect(page).to have_text 'Start a new application'

      click_link_or_button 'Start a new application'

      expect(page)
          .to have_text 'What type of organisation will be running your project'

      click_link_or_button 'Save and continue'

      expect(page)
          .to have_text 'Error: Select the type of organisation that will be ' \
                      'running your project'

    ensure

      Flipper[:new_applications_enabled].disable

    end

  end

  scenario 'New Applications Enabled Flipper turned off should not show Start a new project button' do
    user = FactoryBot.create(
        :user,
        name: 'Jane Doe',
        date_of_birth: Date.new,
        line1: 'line 1',
        phone_number: '123',
        postcode: 'W11AA',
        townCity: 'London',
        county: 'London'
    )

    login_as(user, :scope => :user)

    visit '/'
    expect(page).not_to have_text 'Start a new project'
  end

end
