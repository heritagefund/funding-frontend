class CreateSpend < ActiveRecord::Migration[6.0]
  def change
    create_table :spends, id: :uuid do |t|
      t.text :description
      t.date :date_of_spend
      t.decimal :net_amount 
      t.decimal :vat_amount
      t.decimal :gross_amount
      t.timestamps
      t.references :cost_type, type: :integer, null: false, foreign_key: true
    end
  end
end
