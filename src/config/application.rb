require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module App
  class Application < Rails::Application
    config.load_defaults 7.1
    config.autoload_lib(ignore: %w(assets tasks))
    config.session_store :cookie_store,
      key: '_bealive',
      domain: :all,
      tld_length: 3,
      same_site: :lax,
      secure: Rails.env.production?,
      httponly: true
    config.time_zone = 'Tokyo'
    config.active_record.default_timezone = :local
  end
end
