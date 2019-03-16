require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Remove opened files limit
Rack::Utils.multipart_part_limit = 0

module TheMaterialParser
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.action_cable.mount_path = '/ws'
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
