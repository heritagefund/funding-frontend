class AddSalesForceReferenceForProjectEnquiry < ActiveRecord::Migration[6.0]
  def change
    add_column :pa_project_enquiries, :salesforce_project_enquiry_id, :string
  end
end
