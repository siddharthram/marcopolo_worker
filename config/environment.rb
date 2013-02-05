# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Ximly::Application.initialize!

#require Rails.root.join("config/initializers/settings") #this is not loaded automatically in the assets:precompile task, that's why we need this


Ximly::Application.configure do
	config.assets.initialize_on_precompile = false
	config.action_mailer.default_url_options = { :host => 'mysterious-retreat-8129.herokuapp.com' }
	#config.action_mailer.default_url_options = { :host => 'localhost' }

end