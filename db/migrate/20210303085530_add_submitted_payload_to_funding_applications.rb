class AddSubmittedPayloadToFundingApplications < ActiveRecord::Migration[6.0]
  def change
    add_column :funding_applications, :submitted_payload, :jsonb
  end
end
