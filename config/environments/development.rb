AsciiGame3::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb
  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false #true

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local = true
  config.action_controller.perform_caching             = false

  # Don't care if the mailer can't send
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_url_options = { :host => (ENV['FQDN'] || 'asciigame.com') }
  
  config.active_support.deprecation = true
  config.eager_load = false

  config.after_initialize do
    Bullet.enable = true
    Bullet.bullet_logger = true
    Bullet.add_footer = true
    # Bullet.add_whitelist type: :n_plus_one_query, class_name: "Event", association: :thing
  end
end
