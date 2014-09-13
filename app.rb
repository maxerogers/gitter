require 'rubygems'
require "sinatra"
require 'omniauth-twitter'
require 'twitter'
require 'github_api'
require 'httparty'
require 'json'
require "./models.rb"
require 'thin'

#setup
configure do
  set :server, 'thin'
  enable :sessions
  set :session_secret, "My session secret"
  use OmniAuth::Builder do
    provider :twitter, 'p2xojaAqxCshYaAraH4otANCr', 'TKzK7CRkr71oLRa102V6DF5VQY5BAltvqrkHZWxhXouybcNAxZ'
  end
end

helpers do
  def admin?
    session[:admin]
  end
end

get '/git' do
  response = HTTParty.get('https://api.github.com/repos/honeycodedbear/gitter/commits?since=2014-09-01T12:00:000', headers: {"User-Agent" => 'Git Twit'})
  #puts response.body, response.code, response.message, response.headers.inspect
  json = JSON.parse(response.body)
  puts json[0]
  "
  Commit Sha: #{json[0]["sha"]},<br>
  Commit Message: #{json[0]["commit"]["message"]} <br>
  Commit Time:#{json[0]["commit"]["author"]["date"]} <br>
  #{json[0]}"
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

get '/auth/twitter/callback' do
  session[:admin] = true
  session[:username] = env['omniauth.auth']['info']['name']

  client = Twitter::REST::Client.new do |config|
    config.consumer_key        = "p2xojaAqxCshYaAraH4otANCr"
    config.consumer_secret     = "TKzK7CRkr71oLRa102V6DF5VQY5BAltvqrkHZWxhXouybcNAxZ"
    config.access_token        = env['omniauth.auth'][:credentials][:token]
    config.access_token_secret = env['omniauth.auth'][:credentials][:secret]
  end
  client.update("I'm tweeting with @gem!")
  session[:client] = client
  "#{env['omniauth.auth']}<br><br>#{env['omniauth.auth'][:credentials][:token]}<br>#{env['omniauth.auth'][:credentials][:secret]}"
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

Thread.new do # trivial example work thread
  while true do
     sleep 0.12
     $sum += 1
  end
end

get '/' do
  "Testing background work thread: sum is #{$sum}"
end
