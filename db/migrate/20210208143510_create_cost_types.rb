class CreateCostTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :cost_types, id: :integer do |t|
      t.string :name
      t.timestamps
    end
  end
end
