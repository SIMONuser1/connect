require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# include ApplicationHelper

module CliqueConnect
  class Application < Rails::Application
    config.generators do |generate|
      generate.assets false
      generate.helper false
      generate.test_framework  :test_unit, fixture: false
    end

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Postmark stuff
    # Want to test our APIs and activity logging? Send emails to test@blackhole.postmarkapp.com
    config.action_mailer.delivery_method     = :postmark
    config.action_mailer.postmark_settings   = { api_key: ENV['postmark_api_key'] }
    config.action_mailer.default_url_options = { host: "aiime.io" }

    # paths.clique-connect.views << "clique-connect/views/devise" # may need this for devise views

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
