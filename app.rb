require 'rubygems'
require "sinatra"
require 'omniauth-twitter'
require 'omniauth-github'
require 'twitter'
require 'github_api'
require 'httparty'
require 'json'
require "./models.rb"
require './config/environments' #database configuration
require 'thin'
require 'rest_client'

#setup
configure do
  set :server, 'thin'
  enable :sessions
  set :session_secret, "My session secret"
  use OmniAuth::Builder do
    #I know this bad form but I haven't deployed yet. So Shhhhhhhh
    provider :twitter, 'p2xojaAqxCshYaAraH4otANCr', 'TKzK7CRkr71oLRa102V6DF5VQY5BAltvqrkHZWxhXouybcNAxZ'
    provider :github, '5394720ddae7b4107128', 'e756c8c818b165c5dec5a5a2f88982e0493bd905'
  end
end

helpers do
  def admin?
    session[:admin]
  end
end

get '/git' do
  response = HTTParty.get('https://api.github.com/repos/honeycodedbear/gitter/commits?since=2014-08-01T12:00:000', headers: {"User-Agent" => 'Git Twit'})
  #puts response.body, response.code, response.message, response.headers.inspect
  json = JSON.parse(response.body)
  puts json[0]

  "#{response.body}"

end

get '/public' do
  "This is the public page - everybody is welcome!"
end

get '/private' do
  halt(401,'Not Authorized') unless admin?
  "This is the private page - members only"
end

get '/login' do
  redirect to("/auth/twitter")
end

get '/auth/github/callback' do
    env['omniauth.auth']
end

get '/github_test' do
  "RWAR"
end

get '/auth/twitter/callback' do
  session[:username] = env['omniauth.auth']['info']['name']
  client = Twitter::REST::Client.new do |config|
    config.consumer_key        = "p2xojaAqxCshYaAraH4otANCr"
    config.consumer_secret     = "TKzK7CRkr71oLRa102V6DF5VQY5BAltvqrkHZWxhXouybcNAxZ"
    config.access_token        = env['omniauth.auth'][:credentials][:token]
    config.access_token_secret = env['omniauth.auth'][:credentials][:secret]
  end
  User.new
  client.update("I'm tweeting with @gem!")
  "#{env['omniauth.auth']}<br><br>#{env['omniauth.auth'][:credentials][:token]}<br>#{env['omniauth.auth'][:credentials][:secret]}<br>#{env['omniauth.auth'][:uid]}"
end

get '/auth/failure' do
  params[:message]
end

get '/logout' do
  session[:admin] = nil
  "You are now logged out"
end

#Working Thread
$sum = 0

thr = Thread.new do # trivial example work thread
  while true do
     sleep 0.12
     $sum += 1
     #str = RestClient.get("https://api.github.com/repos/honeycodedbear/gitter/compare/aa5a8bd2c5f5b648ab84344ee3fe90457a3dbb25...b8262a36c765127924b5c424005a695fde02298c")
     str = HTTParty.get("https://api.github.com/repos/honeycodedbear/gitter/compare/aa5a8bd2c5f5b648ab84344ee3fe90457a3dbb25...b8262a36c765127924b5c424005a695fde02298c", headers: {"User-Agent" => 'Git Twit'})
     puts $sum
     puts str
  end
end
thr.join

get '/' do
  "Testing background work thread: sum is #{$sum}"
end

get "/meta_data" do
  erb :meta_data
end
#Compare commits
#curl "https://api.github.com/repos/honeycodedbear/gitter/compare/aa5a8bd2c5f5b648ab84344ee3fe90457a3dbb25...b8262a36c765127924b5c424005a695fde02298c"
#Could read through the number of lines there are and also get the file extension.
#Then we could collect meta data on languages/frameworks this way
#Look for +numbers's. This be an easy way to find the data. Then I should be able to look at all of the file extensions and give it loads of fun data.
#Get commits per hour
#RestClient.get("https://api.github.com/repos/honeycodedbear/gitter/stats/punch_card")
