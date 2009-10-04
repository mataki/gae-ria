require 'appengine-rack'
require 'application'
AppEngine::Rack.configure_app(
  :application => 'mataki-java-test', # Replace your application id.
  :version => 1                     # Replace your application version.
)
run Sinatra::Application
