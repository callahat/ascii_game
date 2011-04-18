# Be sure to restart your server when you modify this file.

AsciiGame3::Application.config.session_store :cookie_store, :key => '_ascii_game3_session'

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
AsciiGame3::Application.config.session_store = :active_record_store

Rails.application.config.session_store :active_record_store

