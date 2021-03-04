class AddSalesForceReferenceForContact < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :salesforce_contact_id, :string
  end
end
