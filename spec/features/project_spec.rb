require 'rails_helper'
include ActionView::Helpers::NumberHelper

RSpec.feature 'Project', type: :feature do

  # This tests for the successful creation of a generic project application,
  # which has almost all fields filled in.
  scenario 'Successful submission of an application' do

    begin

      Flipper[:grant_programme_sff_small].enable
      Flipper[:new_applications_enabled].enable

      salesforce_stub

      user = create(:user)

      funding_application = create(:funding_application)

      funding_application.organisation = user.organisations.first

      funding_application.organisation.update(
          name: "Test Organisation",
          org_type: "church_organisation",
          line1: "10 Downing Street",
          line2: "Westminster",
          townCity: "London",
          county: "London",
          postcode: "SW1A 2AA"
      )

      legal_signatory = build(:legal_signatory)
      legal_signatory.name = "Joe Bloggs"
      legal_signatory.email_address = "joe@bloggs.com"
      legal_signatory.phone_number = "07123456789"

      user.organisations.first.legal_signatories.append(legal_signatory)

      login_as(user, scope: :user)

      visit '/'

      expect(page).to have_text I18n.t("dashboard.funding_applications.buttons.start")

      click_link_or_button I18n.t("dashboard.funding_applications.buttons.start")

      expect(page).to have_text "Which type of application would you like to start?"

      expect(page).to have_text "Grants of £3,000 to £10,000"

      choose "new_application_application_type_sff_small"

      click_link_or_button "Start a new application"

      expect(page).to have_text 'Start now'

      click_link_or_button 'Start now'

      expect(page)
          .to have_text 'Give your project a title or name that we can refer ' \
                      'to it by'

      enter_and_save_project_title("Test project")

      expect(page).to have_text "When will your project happen?"

      fill_in 'project[start_date_day]', with: '31'
      fill_in 'project[start_date_month]', with: '1'
      fill_in 'project[start_date_year]', with: '2031'
      fill_in 'project[end_date_day]', with: '31'
      fill_in 'project[end_date_month]', with: '1'
      fill_in 'project[end_date_year]', with: '2032'

      click_link_or_button 'Save and continue'

      expect(page).to have_text "Is the project taking place at the same " \
                              "location as your organisation's address?"

      choose "Yes, the project is taking place at the same location as my " \
           "organisation's address"

      click_link_or_button 'Save and continue'

      expect(page).to have_text "Describe your idea"

      enter_and_save_project_description("A description of my project")

      expect(page).to have_text "Will capital work be part of your project?"

      enter_and_save_capital_work(false, false)

      expect(page).to have_text "Do you need permission from anyone else to " \
                              "do your project?"

      enter_and_save_project_permission("No, I do not need permission")

      expect(page).to have_text "What difference will your project make?"

      enter_and_save_project_difference("Description of difference")

      expect(page).to have_text "Why is your project important to your community?"

      enter_and_save_project_importance("Description of importance")

      expect(page).to have_text "The heritage of your project: how do you plan " \
                              "to make it available once the project is over?"

      enter_and_save_project_heritage("Description of heritage")

      expect(page).to have_text "Why is your organisation best placed to " \
                              "deliver this project?"

      enter_and_save_project_best_placed("Description of best placed")

      expect(page).to have_text "How will your project involve a wider range " \
                              "of people?"

      enter_and_save_project_involvement("Description of involvement")

      expect(page).to have_text "Will your project achieve any of our other " \
                              "outcomes?"

      choose_and_save_project_outcomes([2,4,6])

      expect(page).to have_text "How much will your project cost"

      add_and_save_project_costs(
          [
              {
                  cost_type: "Professional fees",
                  description: "Costing for professional fees",
                  amount: 500
              },
              {
                  cost_type: "Recruitment",
                  description: "Costing for recruitment",
                  amount: 1000
              }
          ]
      )

      expect(page).to have_text "Are you getting any cash contributions " \
                              "to your project?"

      choose_and_save_cash_contributions(true)

      expect(page).to have_text "Cash contributions"

      add_and_save_cash_contributions(
          [
              {
                  description: "Test cash contribution",
                  secured: "no",
                  amount: 250
              }
          ]
      )

      expect(page).to have_text "Your grant request"

      click_save_and_continue_button

      expect(page).to have_text "Non-cash contributions"

      add_and_save_non_cash_contributions(
          [
              {
                  description: "Test non-cash contribution",
                  amount: 250
              }
          ]
      )

      expect(page).to have_text "Volunteers"

      add_and_save_volunteers(
          [
              {
                  description: "Test volunteer",
                  hours: 25
              }
          ]
      )

      expect(page).to have_text "Evidence of support"

      add_and_save_multiple_evidence_of_support(
          [
              {
                  description: "Test evidence"
              }
          ]
      )

      expect(page).to have_text "Check your answers"
      expect(page).to have_text "Test project"
      expect(page).to have_text "31 Jan 2031"
      expect(page).to have_text "31 Jan 2032"
      expect(page).to have_text "10 Downing Street"
      expect(page).to have_text "Westminster"
      expect(page).to have_text "London"
      expect(page).to have_text "SW1A 2AA"
      expect(page).to have_text "A description of my project"
      expect(page).to have_text "Description of difference"
      expect(page).to have_text "Description of importance"
      expect(page).to have_text "Description of heritage"
      expect(page).to have_text "Description of best placed"
      expect(page).to have_text "Description of involvement"
      expect(page).to have_text "Heritage will be in a better condition"
      expect(page).to have_text "People will have developed skills"
      expect(page).to have_text "People will have a greater wellbeing"
      expect(page).to have_text "Costing for professional fees"
      expect(page).to have_text "Costing for recruitment"
      expect(page).to have_text "Test cash contribution"
      expect(page).to have_text "Test non-cash contribution"
      expect(page).to have_text "Test volunteer"
      expect(page).to have_text "Test evidence"

      click_save_and_continue_button

      expect(page).to have_text "Upload your organisation's governing document"

      click_save_and_continue_button

      expect(page).to have_text "Upload your organisation's accounts"

      click_save_and_continue_button

      expect(page).to have_text "Confirm declaration"

      confirm_and_save_declaration

      expect(page).to have_text "Your application has been submitted"

    ensure

      Flipper[:grant_programme_sff_small].disable
      Flipper[:new_applications_enabled].disable

    end

  end

  private
  # Abstracted method for entering a project title and then
  # submitting the form
  # @param [String] title This argument will be used to populate the title field
  def enter_and_save_project_title(title)
    fill_in "project[project_title]", with: title
    click_save_and_continue_button
  end

  # Abstracted method for entering a project description and then
  # submitting the form
  # @param [String] description This argument will be used to populate the
  #                             description field.
  def enter_and_save_project_description(description)
    fill_in "project[description]", with: description
    click_save_and_continue_button
  end

  # Abstracted method for entering project capital work choice
  # @param [Boolean] capital_work_option Used to determine which radio button
  #                                     option to choose.
  # @param [Boolean] condition_survey Used to determine whether or not to attach
  #                                   a file to upload.
  def enter_and_save_capital_work(capital_work_option, condition_survey)

    if capital_work_option

      choose "Yes, capital work is part of my project"

      if condition_survey

        attach_file(
            "Upload a file",
            Rails.root + "spec/fixtures/files/example.txt"
        )
        click_link_or_button "Add condition survey"
        expect(page).to have_text "Condition Survey File"

      end

    else

      choose "No, capital work is not part of my project"

    end

    click_save_and_continue_button
  end

  # Abstracted method for entering and saving project permission
  # and a description if relevant
  # @param [String] permission This argument will be used to choose a radio
  #                            button option.
  # @param [String] description This argument will be used to populate the
  #                             description field if passed, and only if the
  #                             permission argument contains a value which maps
  #                             to a radio button with an accompanying
  #                             description textarea.
  def enter_and_save_project_permission(permission, description = nil)

    choose permission

    if description.present?
      fill_in "project[permission_description_yes]",
              with: description if permission.include? "Yes"
      fill_in "project[permission_description_not_sure]",
              with: description if permission.include? "Not sure"
    end

    click_save_and_continue_button

  end

  # Abstracted method for entering a description of the difference
  # that a project will make and then submitting the form
  # @param [String] description This argument will be used to populate the
  #                             description field if passed.
  def enter_and_save_project_difference(description = nil)
    fill_in "project[difference]", with: description if description.present?
    click_save_and_continue_button
  end

  # Abstracted method for entering a description of the importance
  # that a project has to a community and then submitting the form
  # @param [String] description This argument will be used to populate the
  #                             description field if passed.
  def enter_and_save_project_importance(description = nil)
    fill_in "project[matter]", with: description if description.present?
    click_save_and_continue_button
  end

  # Abstracted method for entering a description of how a project's heritage
  # will be made available and then submitting the form
  # @param [String] description This argument will be used to populate the
  #                             description field if passed.
  def enter_and_save_project_heritage(description = nil)
    fill_in "project[heritage_description]",
            with: description if description.present?
    click_save_and_continue_button
  end

  # Abstracted method for entering a description of the reason that an
  # organisation is best placed to deliver a project and then
  # submitting the form
  # @param [String] description This argument will be used to populate the
  #                             description field if passed.
  def enter_and_save_project_best_placed(description = nil)
    fill_in "project[best_placed_description]",
            with: description if description.present?
    click_save_and_continue_button
  end

  # Abstracted method for entering a description of a project will
  # involve a wider range of people and then submitting the form
  # @param [String] description This argument will be used to populate the
  #                             description field.
  def enter_and_save_project_involvement(description)
    fill_in "project[involvement_description]",
            with: description if description.present?
    click_save_and_continue_button
  end

  # Abstracted method for checking project outcome checkboxes
  # and then submitting the form
  # @param [Array] outcomes Array of integers which map to project outcomes
  def choose_and_save_project_outcomes(outcomes)

    check "Heritage will be in a better condition" if outcomes.include?(2)
    check "Heritage will be better identified and explained" if
        outcomes.include?(3)
    check "People will have developed skills" if outcomes.include?(4)
    check "People will have learned about heritage, leading to change in " \
          "ideas and actions" if outcomes.include?(5)
    check "People will have greater wellbeing" if
        outcomes.include?(6)
    check "The funded organisation will be more resilient" if
        outcomes.include?(7)
    check "The local area will be a better place to live, work or visit" if
        outcomes.include?(8)
    check "The local economy will be boosted" if outcomes.include?(9)

    click_save_and_continue_button

  end

  # Abstracted method for adding multiple project costs.
  # This method will call the add_and_save_project_cost method for
  # every item in the @costs parameter and then submit the form
  # @param [Array] costs Should contain multiple hashes, each containing a key
  #                      of @cost_type with a String value, a key of
  #                      @description with a String value and a key of @amount
  #                      with an Integer value
  def add_and_save_project_costs(costs)

    costs.each do |cost|
      add_and_save_project_cost(
          cost[:cost_type],
          cost[:description],
          cost[:amount]
      )
    end

    click_save_and_continue_button
  end

  # Abstracted method for adding an individual project cost and then
  # asserting that the values added are present on the page after form
  # submission
  # @param [String] cost_type This argument will be used to select a value
  #                           from the relevant select field.
  # @param [String] description This argument will be used to populate the
  #                             description field.
  # @param [Integer] amount This argument will be used to populate the amount
  #                         field.
  def add_and_save_project_cost(cost_type, description, amount)

    select(cost_type, from: "Cost type")

    fill_in "project[project_costs_attributes][0][description]",
            with: description
    fill_in "project[project_costs_attributes][0][amount]",
            with: amount

    click_link_or_button "Add this cost"

    expect(page).to have_text cost_type
    expect(page).to have_text description
    expect(page).to have_text number_to_currency(
                                  amount.abs,
                                  strip_insignificant_zeros: true
                              )

  end

  # Abstracted method for choosing a radio button option on the Are you
  # getting cash contributions to your project? page, and then submitting the
  # form
  # @param [Boolean] cash_contributions_option Used to determine which radio
  #                                            button to select
  def choose_and_save_cash_contributions(cash_contributions_option)
    if cash_contributions_option
      choose "Yes, I am getting cash contributions"
    else
      choose "No, I am not getting cash contributions"
    end

    click_save_and_continue_button

  end

  # Abstracted method for adding multiple cash-contributions.
  # This method will call the add_and_save_cash_contribution method for
  # every item in the @cash_contributions parameter and then submit the form
  # @param [Array] cash_contributions Should contain multiple hashes,
  #                                   each containing a key of @description
  #                                   with a String value, a key of @amount
  #                                   with an Integer value, and a key of
  #                                   @secured with a String value
  def add_and_save_cash_contributions(cash_contributions)

    cash_contributions.each do |cc|
      add_and_save_cash_contribution(
          cc[:description],
          cc[:secured],
          cc[:amount]
      )
    end

    click_save_and_continue_button

  end

  # Abstracted method for adding an individual cash contribution and then
  # asserting that the values added are present on the page after form
  # submission
  # @param [String] description This argument will be used to populate the
  #                             description field.
  # @param [String] secured This argument will be used to choose a radio
  #                         button on the page. If secured matches the value of
  #                         "Yes and I can provide evidence", then a file will
  #                         also be attached.
  # @param [Integer] amount This argument will be used to populate the amount
  #                         field.
  def add_and_save_cash_contribution(description, secured, amount)

    fill_in "project[cash_contributions_attributes][0][description]",
            with: description

    choose secured

    if secured == "Yes and I can provide evidence"
      attach_file(
          "Evidence could be a letter from the contributor, or a copy of " \
            "bank statements to show the funds.",
          Rails.root + "spec/fixtures/files/example.txt"
      )
    end

    fill_in "project[cash_contributions_attributes][0][amount]",
            with: amount

    click_link_or_button "Add cash contribution"

    expect(page).to have_text description
    expect(page).to have_text number_to_currency(
                                  amount.abs,
                                  strip_insignificant_zeros: true
                              )
    expect(page).to have_text "Evidence attached" if
        secured == "Yes and I can provide evidence"

  end

  # Abstracted method for adding multiple non-cash-contributions.
  # This method will call the add_and_save_non_cash_contribution method for
  # every item in the @non_cash_contributions parameter and then submit the form
  # @param [Array] non_cash_contributions Should contain multiple hashes,
  #                                       each containing a key of @description
  #                                       with a String value, and a key of
  #                                       @amount with an Integer value.
  def add_and_save_non_cash_contributions(non_cash_contributions)

    non_cash_contributions.each do |ncc|
      add_and_save_non_cash_contribution(
          ncc[:description],
          ncc[:amount]
      )
    end

    click_save_and_continue_button

  end

  # Abstracted method for adding an individual non-cash contribution and then
  # asserting that the values added are present on the page after form
  # submission
  # @param [String] description This argument will be used to populate the
  #                             description field.
  # @param [Integer] amount This argument will be used to populate the amount
  #                         field.
  def add_and_save_non_cash_contribution(description, amount)

    fill_in "project[non_cash_contributions_attributes][0][description]",
            with: description

    fill_in "project[non_cash_contributions_attributes][0][amount]",
            with: amount

    click_link_or_button "Add non-cash contribution"

    expect(page).to have_text description
    expect(page).to have_text number_to_currency(
                                  amount.abs,
                                  strip_insignificant_zeros: true
                              )

  end

  # Abstracted method for adding multiple volunteers.
  # This method will call the add_and_save_volunteer method for every item in
  # the @volunteers parameter and then submit the form
  # @param [Array] volunteers Should contain multiple hashes, each containing
  #                           a key of @description with a String value, and a
  #                           key of @hours with an Integer value.
  def add_and_save_volunteers(volunteers)

    volunteers.each do |v|
      add_and_save_volunteer(
          v[:description],
          v[:hours]
      )
    end

    click_save_and_continue_button

  end

  # Abstracted method for adding an individual volunteer and then asserting
  # that the values added are present on the page after form submission
  # @param [String] description This argument will be used to populate the
  #                             description field.
  # @param [Integer] hours This argument will be used to populate the hours
  #                       field.
  def add_and_save_volunteer(description, hours)

    fill_in "project[volunteers_attributes][0][description]",
            with: description

    fill_in "project[volunteers_attributes][0][hours]",
            with: hours

    click_link_or_button "Add this volunteer"

    expect(page).to have_text description
    expect(page).to have_text hours

  end

  # Abstracted method for adding multiple pieces of supporting evidence.
  # This method will call the add_and_save_evidence_of_support method
  # for every item in the @evidence parameter and then submit the form
  # @param [Array] evidence Should contain multiple hashes, each containing
  #                         a key of @description with a String value
  def add_and_save_multiple_evidence_of_support(evidence)

    evidence.each do |e|
      add_and_save_evidence_of_support(e[:description])
    end

    click_save_and_continue_button
  end

  # Abstracted method for adding an individual piece of supporting evidence
  # and then asserting that the values are present on the page after form
  # submission
  # @param [String] description This argument will be used to populate the
  #                             evidence of support description.
  def add_and_save_evidence_of_support(description)

    fill_in "project[evidence_of_support_attributes][0][description]",
            with: description

    attach_file("Upload a file", Rails.root + "spec/fixtures/files/example.txt")

    click_link_or_button "Add evidence"

    expect(page).to have_text description
    expect(page).to have_text "example.txt"

  end

  # Abstracted method for checking the declaration confirmation and then
  # submitting the form
  def confirm_and_save_declaration
    check "I have read and agreed with the declaration"
    click_link_or_button "Submit application"
  end

  # Abstracted method for clicking the 'Save and continue' form button
  def click_save_and_continue_button
    click_link_or_button "Save and continue"
  end

  # As we are using WebMock to disable outbound connections, we will receive
  # a warning log at the point that this test tries to connect to Salesforce
  # unless we stub the request, which this method does
  def salesforce_stub
    stub_request(:post, "https://test.salesforce.com/services/oauth2/token").
        to_return(status: 200, body: "", headers: {})
  end

end
