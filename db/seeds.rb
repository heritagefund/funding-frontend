# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create(email: 'test@example.com', encrypted_password: User.new.send(:password_digest, '123456')).confirm

# Flipper gates necessary to run the application in a given state are not added when running
# a new instance of the application on a local development machine. This occurs because the
# database is created from the schema.rb file rather than from running the database migrations
# from scratch (which would have the effect of inserting rows into the flipper_gates table).

flipper_gates_sql = <<-EOL
    INSERT INTO flipper_gates (feature_key, key, value, created_at, updated_at) VALUES ('covid_banner_enabled', 'boolean', 'true', now(), now());
    INSERT INTO flipper_gates (feature_key, key, value, created_at, updated_at) VALUES ('registration_enabled', 'boolean', 'true', now(), now());
    INSERT INTO flipper_gates (feature_key, key, value, created_at, updated_at) VALUES ('grant_programme_sff_small', 'boolean', 'true', now(), now());
    INSERT INTO flipper_gates (feature_key, key, value, created_at, updated_at) VALUES ('new_applications_enabled', 'boolean', 'true', now(), now());
    INSERT INTO flipper_gates (feature_key, key, value, created_at, updated_at) VALUES ('project_enquiries_enabled', 'boolean', 'true', now(), now());
    INSERT INTO flipper_gates (feature_key, key, value, created_at, updated_at) VALUES ('expressions_of_interest_enabled', 'boolean', 'true', now(), now());
    INSERT INTO flipper_gates (feature_key, key, value, created_at, updated_at) VALUES ('payment_requests_enabled', 'boolean', 'true', now(), now());
EOL

connection = ActiveRecord::Base.connection()

flipper_gates_sql.split(';').each do |s|
    connection.execute(s.strip) unless s.strip.empty?
end
