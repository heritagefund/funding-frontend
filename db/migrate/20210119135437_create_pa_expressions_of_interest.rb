class CreatePaExpressionsOfInterest < ActiveRecord::Migration[6.0]
  def change
    create_table :pa_expressions_of_interest, id: :uuid do |t|
      t.references  :pre_application, type: :uuid, null: false, foreign_key: true 
      t.text :heritage_focus
      t.text :what_project_does
      t.text :programme_outcomes
      t.text :project_reasons
      t.text :project_timescales
      t.text :overall_cost
      t.text :working_title
      t.integer :potential_funding_amount
      t.text :likely_submission_description
      t.text :previous_contact_name
      t.timestamps
    end
  end
end
