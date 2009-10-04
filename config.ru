require 'appengine-rack'
require 'application'
AppEngine::Rack.configure_app(
  :application => 'gae-ria', # Replace your application id.
  :version => 1                     # Replace your application version.
)
run Sinatra::Application
