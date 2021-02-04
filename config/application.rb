require_relative 'boot'

require 'rails/all'
require 'view_component/engine'
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

HOSTNAME = ENV['HOSTNAME']

module FundingFrontendRuby
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0
    config.assets.paths << Rails.root.join('node_modules')
    config.i18n.default_locale = :'en-GB'
    config.i18n.fallbacks = true
    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid

      hacker = Module.new do
        def options_for_migration
          ar = Rails.application.config.generators.active_record
          return super unless %i[belongs_to references].include?(type) && \
                              ar[:primary_key_type] == :uuid
    
          { type: :uuid }.merge(super)
        end
      end
      require 'rails/generators/generated_attribute'
      Rails::Generators::GeneratedAttribute.prepend hacker
    end

    # Autoload models from subdirectories in the models/application/common directory
    # For each additional subdirectory, we will need to appened to config.autoload_paths
    config.autoload_paths += Dir[Rails.root.join("app", "models", "application", "common")]
    config.autoload_paths += Dir[Rails.root.join("app", "models", "pre_application")]
    config.autoload_paths += Dir[Rails.root.join("lib", "apis", "salesforce")]

    # Load locale dictionaries from subdirectories in the config/locales directory. We 
    # have to apply this setting, as the default locale loading mechanism in Rails does not 
    # load locale dictionaries in nested directories
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]

    # Specify available locales for the application
    config.i18n.available_locales = [:en, :"en-GB", :cy]
    
    # config.active_record.schema_format = :sql

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
