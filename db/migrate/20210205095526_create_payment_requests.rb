class CreatePaymentRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :payment_requests, id: :uuid do |t|
      t.decimal :amount_requested
      t.jsonb :payload_submitted
      t.timestamps
    end
  end
end
