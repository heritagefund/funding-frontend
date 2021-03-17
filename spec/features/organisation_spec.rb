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

      expect(page).to have_text(
        I18n.t('dashboard.funding_applications.buttons.start')
      )

      click_link_or_button I18n.t('dashboard.funding_applications.buttons.start')

      expect(page.title).to include(I18n.t('organisation.type.page_title'))

      expect(page).to have_text I18n.t('organisation.type.page_heading')

      choose I18n.t('organisation.type.labels.registered_charity')

      click_link_or_button 'Save and continue'

      expect(page.title).to include(I18n.t('organisation.numbers.page_title'))

      expect(page)
          .to have_text I18n.t('organisation.numbers.labels.company_number')
      expect(page)
          .to have_text I18n.t('organisation.numbers.labels.charity_number')

      fill_in 'organisation[charity_number]', with: '123'

      click_link_or_button 'Save and continue'

      set_address(title_field = 'Organisation name')

      expect(page.title).to include(I18n.t('organisation.mission.page_title'))

      expect(page).to have_text I18n.t('organisation.mission.page_heading')

      check I18n.t('organisation.mission.labels.female_led')

      click_link_or_button 'Save and continue'

      expect(page.title).to include(I18n.t('organisation.signatories.page_title'))

      expect(page).to have_text I18n.t('organisation.signatories.page_heading')

      fill_in I18n.t('organisation.signatories.labels.full_name'), match: :first, with: 'Jane Doe'
      fill_in I18n.t('organisation.signatories.labels.email_address'), match: :first, with: 'test@example.com'
      fill_in I18n.t('organisation.signatories.labels.phone_number'), match: :first, with: '123'

      click_link_or_button 'Save and continue'

      expect(page.title).to include(I18n.t('organisation.summary.page_title'))
      expect(page).to have_text(I18n.t('organisation.summary.page_heading'))
      expect(page).to have_text(
        I18n.t('organisation.type.labels.registered_charity')
      )
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
      expect(organisation.legal_signatories.first.email_address).to eq('test@example.com')
      expect(organisation.legal_signatories.first.phone_number).to eq('123')

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
      expect(page).to have_text(
        I18n.t('dashboard.funding_applications.buttons.start')
      )

      click_link_or_button I18n.t('dashboard.funding_applications.buttons.start')

      expect(page.title).to include(I18n.t('organisation.type.page_title'))

      expect(page).to have_text I18n.t('organisation.type.page_heading')

      click_link_or_button 'Save and continue'

      expect(page).to have_text(
        "#{I18n.t('generic.error')}: #{I18n.t('activerecord.errors.models.organisation.attributes.org_type.blank')}"
      )

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

    expect(page).not_to have_text(
      I18n.t('dashboard.funding_applications.buttons.start')
    )

  end

end
