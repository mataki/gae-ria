require 'rubygems'
require 'sinatra'
require 'dm-core'
require 'haml'
require 'request_log_analyzer'

DataMapper.setup(:default, "appengine://auto")

class LogFile
  include DataMapper::Resource

  property :id, Serial
  property :split, Integer
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
  @htmls = @logs.map do |log|
    sio = StringIO.new
    RequestLogAnalyzer::Controller.build(:output       => RequestLogAnalyzer::Output::HTML,
                                         :file         => sio,
                                         :source_files => StringIO.new(log.content),
                                         :no_progress  => true
                                         ).run!
    if out = sio.string
      ah = AnalizedHtml.create(:content => out, :filename => log.filename)
      log.destroy
    end
    ah
  end
  haml :analyze
end

get '/r/:id' do
  if html = AnalizedHtml.get(params[:id])
    html.content
  else
    "Not Found"
  end
end
