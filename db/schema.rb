# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_03_03_102649) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "addresses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "line1"
    t.string "line2"
    t.string "line3"
    t.string "town_city"
    t.string "county"
    t.string "postcode"
    t.string "udprn"
    t.string "lat"
    t.string "long"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "cash_contributions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "amount"
    t.string "description"
    t.integer "secured"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "project_id", null: false
    t.index ["project_id"], name: "index_cash_contributions_on_project_id"
  end

  create_table "cost_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "declarations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "grant_programme"
    t.string "declaration_type"
    t.jsonb "json"
    t.integer "version"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "evidence_of_support", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "project_id", null: false
    t.index ["project_id"], name: "index_evidence_of_support_on_project_id"
  end

  create_table "flipper_features", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["key"], name: "index_flipper_features_on_key", unique: true
  end

  create_table "flipper_gates", force: :cascade do |t|
    t.string "feature_key", null: false
    t.string "key", null: false
    t.string "value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["feature_key", "key", "value"], name: "index_flipper_gates_on_feature_key_and_key_and_value", unique: true
  end

  create_table "funding_application_addresses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "address_id", null: false
    t.uuid "funding_application_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["address_id"], name: "index_funding_application_addresses_on_address_id"
    t.index ["funding_application_id"], name: "index_funding_application_addresses_on_funding_application_id"
  end

  create_table "funding_applications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "declaration"
    t.text "declaration_description"
    t.boolean "declaration_keep_informed"
    t.boolean "declaration_user_research"
    t.string "project_reference_number"
    t.string "salesforce_case_id"
    t.string "salesforce_case_number"
    t.datetime "submitted_on"
    t.uuid "organisation_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.jsonb "submitted_payload"
    t.index ["organisation_id"], name: "index_funding_applications_on_organisation_id"
  end

  create_table "funding_applications_dclrtns", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "declaration_id", null: false
    t.uuid "funding_application_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["declaration_id"], name: "index_funding_applications_dclrtns_on_declaration_id"
    t.index ["funding_application_id"], name: "index_funding_applications_dclrtns_on_funding_application_id"
  end

  create_table "funding_applications_pay_reqs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "funding_application_id", null: false
    t.uuid "payment_request_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["funding_application_id"], name: "index_funding_applications_pay_reqs_on_funding_application_id"
    t.index ["payment_request_id"], name: "index_funding_applications_pay_reqs_on_payment_request_id"
  end

  create_table "funding_applications_people", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "person_id", null: false
    t.uuid "funding_application_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["funding_application_id"], name: "index_funding_applications_people_on_funding_application_id"
    t.index ["person_id"], name: "index_funding_applications_people_on_person_id"
  end

  create_table "legal_signatories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "email_address"
    t.string "phone_number"
    t.uuid "organisation_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["organisation_id"], name: "index_legal_signatories_on_organisation_id"
  end

  create_table "non_cash_contributions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "amount"
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "project_id", null: false
    t.index ["project_id"], name: "index_non_cash_contributions_on_project_id"
  end

  create_table "org_income_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "org_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "organisations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "line1"
    t.string "townCity"
    t.string "county"
    t.string "postcode"
    t.string "company_number"
    t.string "charity_number"
    t.integer "charity_number_ni"
    t.string "name"
    t.string "line2"
    t.string "line3"
    t.integer "org_type"
    t.string "mission", default: [], array: true
    t.string "salesforce_account_id"
    t.string "custom_org_type"
  end

  create_table "organisations_org_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organisation_id", null: false
    t.uuid "org_type_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["org_type_id"], name: "index_organisations_org_types_on_org_type_id"
    t.index ["organisation_id"], name: "index_organisations_org_types_on_organisation_id"
  end

  create_table "pa_expressions_of_interest", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "pre_application_id", null: false
    t.text "heritage_focus"
    t.text "what_project_does"
    t.text "programme_outcomes"
    t.text "project_reasons"
    t.text "project_timescales"
    t.text "overall_cost"
    t.text "working_title"
    t.integer "potential_funding_amount"
    t.text "likely_submission_description"
    t.text "previous_contact_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "salesforce_expression_of_interest_id"
    t.index ["pre_application_id"], name: "index_pa_expressions_of_interest_on_pre_application_id"
  end

  create_table "pa_project_enquiries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "pre_application_id", null: false
    t.text "previous_contact_name"
    t.text "heritage_focus"
    t.text "what_project_does"
    t.text "programme_outcomes"
    t.text "project_reasons"
    t.text "project_participants"
    t.text "project_timescales"
    t.text "project_likely_cost"
    t.text "working_title"
    t.integer "potential_funding_amount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "salesforce_project_enquiry_id"
    t.index ["pre_application_id"], name: "index_pa_project_enquiries_on_pre_application_id"
  end

  create_table "payment_details", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "account_name"
    t.text "account_number"
    t.text "sort_code"
    t.uuid "funding_application_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "building_society_roll_number"
    t.text "payment_reference"
    t.string "replay_number"
    t.index ["funding_application_id"], name: "index_payment_details_on_funding_application_id"
  end

  create_table "payment_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "amount_requested"
    t.jsonb "payload_submitted"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "payment_requests_spends", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "payment_request_id", null: false
    t.uuid "spend_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["payment_request_id"], name: "index_payment_requests_spends_on_payment_request_id"
    t.index ["spend_id"], name: "index_payment_requests_spends_on_spend_id"
  end

  create_table "people", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.date "date_of_birth"
    t.string "email"
    t.string "phone_number"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "position"
  end

  create_table "people_addresses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "address_id", null: false
    t.uuid "person_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["address_id"], name: "index_people_addresses_on_address_id"
    t.index ["person_id"], name: "index_people_addresses_on_person_id"
  end

  create_table "pre_applications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organisation_id", null: false
    t.integer "user_id", null: false
    t.text "project_reference_number"
    t.text "salesforce_case_id"
    t.text "salesforce_case_number"
    t.datetime "submitted_on"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.jsonb "submitted_payload"
    t.index ["organisation_id"], name: "index_pre_applications_on_organisation_id"
    t.index ["user_id"], name: "index_pre_applications_on_user_id"
  end

  create_table "project_costs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "cost_type"
    t.integer "amount"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "project_id", null: false
    t.index ["project_id"], name: "index_project_costs_on_project_id"
  end

  create_table "projects", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "project_title"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id", null: false
    t.date "start_date"
    t.date "end_date"
    t.text "description"
    t.string "line1"
    t.string "line2"
    t.string "line3"
    t.string "townCity"
    t.string "county"
    t.string "postcode"
    t.text "difference"
    t.text "matter"
    t.text "heritage_description"
    t.text "best_placed_description"
    t.text "involvement_description"
    t.integer "permission_type"
    t.text "permission_description"
    t.boolean "capital_work"
    t.text "declaration_reasons_description"
    t.boolean "user_research_declaration", default: false
    t.boolean "keep_informed_declaration", default: false
    t.boolean "outcome_2"
    t.boolean "outcome_3"
    t.boolean "outcome_4"
    t.boolean "outcome_5"
    t.boolean "outcome_6"
    t.boolean "outcome_7"
    t.boolean "outcome_8"
    t.boolean "outcome_9"
    t.text "outcome_2_description"
    t.text "outcome_3_description"
    t.text "outcome_4_description"
    t.text "outcome_5_description"
    t.text "outcome_6_description"
    t.text "outcome_7_description"
    t.text "outcome_8_description"
    t.text "outcome_9_description"
    t.boolean "is_partnership", default: false
    t.text "partnership_details"
    t.uuid "funding_application_id"
    t.index ["funding_application_id"], name: "index_projects_on_funding_application_id"
    t.index ["user_id"], name: "index_projects_on_user_id"
  end

  create_table "released_forms", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "project_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.jsonb "payload"
    t.integer "form_type"
    t.index ["project_id"], name: "index_released_forms_on_project_id"
  end

  create_table "spends", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "description"
    t.date "date_of_spend"
    t.decimal "net_amount"
    t.decimal "vat_amount"
    t.decimal "gross_amount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "cost_type_id", null: false
    t.index ["cost_type_id"], name: "index_spends_on_cost_type_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.date "date_of_birth"
    t.string "name"
    t.string "line1"
    t.string "line2"
    t.string "line3"
    t.string "townCity"
    t.string "county"
    t.string "postcode"
    t.string "phone_number"
    t.uuid "person_id"
    t.text "communication_needs"
    t.string "language_preference"
    t.boolean "agrees_to_contact"
    t.boolean "agrees_to_user_research"
    t.string "salesforce_contact_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["person_id"], name: "index_users_on_person_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_organisations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "user_id", null: false
    t.uuid "organisation_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["organisation_id"], name: "index_users_organisations_on_organisation_id"
    t.index ["user_id"], name: "index_users_organisations_on_user_id"
  end

  create_table "volunteers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "description"
    t.integer "hours"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "project_id", null: false
    t.index ["project_id"], name: "index_volunteers_on_project_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "cash_contributions", "projects"
  add_foreign_key "evidence_of_support", "projects"
  add_foreign_key "funding_application_addresses", "addresses"
  add_foreign_key "funding_application_addresses", "funding_applications"
  add_foreign_key "funding_applications", "organisations"
  add_foreign_key "funding_applications_dclrtns", "declarations"
  add_foreign_key "funding_applications_dclrtns", "funding_applications"
  add_foreign_key "funding_applications_pay_reqs", "funding_applications"
  add_foreign_key "funding_applications_pay_reqs", "payment_requests"
  add_foreign_key "funding_applications_people", "funding_applications"
  add_foreign_key "funding_applications_people", "people"
  add_foreign_key "non_cash_contributions", "projects"
  add_foreign_key "organisations_org_types", "org_types"
  add_foreign_key "organisations_org_types", "organisations"
  add_foreign_key "pa_expressions_of_interest", "pre_applications"
  add_foreign_key "pa_project_enquiries", "pre_applications"
  add_foreign_key "payment_details", "funding_applications"
  add_foreign_key "payment_requests_spends", "payment_requests"
  add_foreign_key "payment_requests_spends", "spends"
  add_foreign_key "people_addresses", "addresses"
  add_foreign_key "people_addresses", "people"
  add_foreign_key "pre_applications", "organisations"
  add_foreign_key "pre_applications", "users"
  add_foreign_key "project_costs", "projects"
  add_foreign_key "projects", "funding_applications"
  add_foreign_key "projects", "users"
  add_foreign_key "spends", "cost_types"
  add_foreign_key "users", "people"
  add_foreign_key "users_organisations", "organisations"
  add_foreign_key "users_organisations", "users"
  add_foreign_key "volunteers", "projects"
end
