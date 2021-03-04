class AddSalesForceReferenceForExpressionOfInterest < ActiveRecord::Migration[6.0]
  def change
    add_column :pa_expressions_of_interest, :salesforce_expression_of_interest_id, :string
  end
end
