class CreateFundingApplicationsPayReqs < ActiveRecord::Migration[6.0]
  def change
    create_table :funding_applications_pay_reqs, id: :uuid do |t|
      t.references :funding_application, type: :uuid, null: false, foreign_key: true
      t.references :payment_request, type: :uuid, null: false, foreign_key: true
      t.timestamps
    end
  end
end
