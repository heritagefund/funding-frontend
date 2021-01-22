class AddSubmittedPayloadToPreApplications < ActiveRecord::Migration[6.0]
  def change
    add_column :pre_applications, :submitted_payload, :jsonb
  end
end
