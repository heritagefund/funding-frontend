
require 'flipper/adapters/active_record'

if ActiveRecord::Base.connection.table_exists? :flipper_features
  Flipper.configure do |config|
    config.default do
      adapter = Flipper::Adapters::ActiveRecord.new
      Flipper.new(adapter)
    end
    # Flipper gates toggle app features on and off. Adding the flippers 
    # here creates a row in flipper_features.
    # To control toggles - see README
    Flipper[:covid_banner_enabled].add
    Flipper[:registration_enabled].add
    Flipper[:new_applications_enabled].add
    Flipper[:grant_programme_sff_small].add
    Flipper[:project_enquiries_enabled].add
    Flipper[:expressions_of_interest_enabled].add
    Flipper[:payment_requests_enabled].add
  end
end