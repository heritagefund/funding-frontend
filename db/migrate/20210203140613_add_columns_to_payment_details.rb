class AddColumnsToPaymentDetails < ActiveRecord::Migration[6.0]
  def change
    add_column :payment_details, :building_society_roll_number, :string
    add_column :payment_details, :payment_reference, :text
    add_column :payment_details, :replay_number, :string
  end
end
