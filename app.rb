require "sinatra"
require 'omniauth-twitter'
require 'twitter'
require "./models.rb"

#setup
configure do
  enable :sessions
  use OmniAuth::Builder do
    provider :twitter, 'p2xojaAqxCshYaAraH4otANCr', 'TKzK7CRkr71oLRa102V6DF5VQY5BAltvqrkHZWxhXouybcNAxZ'
  end
end

helpers do
  def admin?
    session[:admin]
  end
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

  session[:client] = Twitter::REST::Client.new do |config|
    config.consumer_key        = "p2xojaAqxCshYaAraH4otANCr"
    config.consumer_secret     = "TKzK7CRkr71oLRa102V6DF5VQY5BAltvqrkHZWxhXouybcNAxZ"
    config.access_token        = env['omniauth.auth'][:credentials][:token]
    config.access_token_secret = env['omniauth.auth'][:credentials][:secret]
  end
  session[:client].update("I'm tweeting with @gem!")
  "#{env['omniauth.auth']}<br><br>#{env['omniauth.auth'][:credentials][:token]}<br>#{env['omniauth.auth'][:credentials][:secret]}"
end

get '/auth/failure' do
  params[:message]
end

get '/logout' do
  session[:admin] = nil
  "You are now logged out"
end
