class AddEoiReferenceToPaExpressionsOfInterest < ActiveRecord::Migration[6.1]
  def change
    add_column :pa_expressions_of_interest, :salesforce_eoi_reference, :string
  end
end
