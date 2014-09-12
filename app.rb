require "sinatra"
require 'omniauth-twitter'
require "./models.rb"
#setup
configure do
  enable :sessions
  use OmniAuth::Builder do
    provider :twitter, ENV['p2xojaAqxCshYaAraH4otANCr'], ENV['TKzK7CRkr71oLRa102V6DF5VQY5BAltvqrkHZWxhXouybcNAxZ']
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
  session[:admin] = true
  "You are now logged in"
end

get '/logout' do
  session[:admin] = nil
  "You are now logged out"
end
