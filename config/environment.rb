# Load the rails application
require File.expand_path('../application', __FILE__)

ActiveSupport::Dependencies.autoload_paths << ::Rails.root.to_s+"/lib"


# Initialize the rails application
AsciiGame3::Application.initialize!
