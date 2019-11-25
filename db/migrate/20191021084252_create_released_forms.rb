class CreateReleasedForms < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
    CREATE TYPE form_type AS ENUM ('permission-to-start', 'completion-report' );
  SQL
    create_table :released_forms, id: :uuid do |t|
      t.references :projects
      t.column :type, :form_type
      t.timestamps
      t.jsonb 'payload'
    end
  end

  def down
    drop_table :released_forms
    execute <<-SQL
      DROP TYPE article_status;
    SQL
  end
end