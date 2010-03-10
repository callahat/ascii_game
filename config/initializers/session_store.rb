# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_ascii_game_session',
  :secret      => '94a08d3a46ca005f3b5e482cb5217bda4e84e5da309a507e7e8f598f176956f982cc013744f2db814b1a2ca2a7bf2aba184aefa9f1dcdcbeda58f42407736e20'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
ActionController::Base.session_store = :active_record_store
