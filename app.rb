require "sinatra"
require 'omniauth-twitter'
require "./models.rb"
#setup
configure do
  enable :sessions
  use OmniAuth::Builder do
    provider :twitter, ENV['CONSUMER_KEY'], ENV['CONSUMER_SECRET']
  end
end

get "/" do
  erb :index
end
