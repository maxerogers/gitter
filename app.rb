require "sinatra"
require "./models.rb"
#setup
enable :sessions
set :session_secret, "My session secret"

get "/" do
  "hello I am gitter"
end
