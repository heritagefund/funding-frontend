class CreatePaymentRequestsSpend < ActiveRecord::Migration[6.0]
  def change
    create_table :payment_requests_spends, id: :uuid do |t|
      t.references :payment_request, type: :uuid, null: false, foreign_key: true
      t.references :spend, type: :uuid, null: false, foreign_key: true
      t.timestamps
    end
  end
end
