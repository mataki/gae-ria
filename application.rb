require 'rubygems'
require 'sinatra'
require 'dm-core'
require 'haml'
require 'request_log_analyzer'

# Configure DataMapper to use the App Engine datastore
DataMapper.setup(:default, "appengine://auto")

# Create your model class
class LogFile
  include DataMapper::Resource

  property :id, Serial
  property :content, Text
  property :filename, Text
end

class AnalizedHtml
  include DataMapper::Resource

  property :id, Serial
  property :content, Text
  property :filename, Text
end

# Make sure our template can use <%=h
helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

get '/' do
  haml :index
end

post '/' do
  log_file = LogFile.create(:filename => File.extname(params[:file][:filename]), :content => params[:file][:tempfile].read)
  redirect '/'
end

get '/analyze' do
  @logs = LogFile.all
  sio = StringIO.new
  @htmls = @logs.map do |log|
    RequestLogAnalyzer::Controller.build(:output       => RequestLogAnalyzer::Output::HTML,
                                         :file         => sio,
                                         :source_files => log.content,
                                         :no_progress  => true
                                         ).run!
    if out = sio.string
      AnalizedHtml.create(:content => out, :filename => log.filename)
    end
  end.conpact
  haml :analyze
end
