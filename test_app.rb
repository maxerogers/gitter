require "sinatra"

get "/" do
	#http://localhost:4567/
	#run by typing in 'ruby test.app.rb'
	erb :index
end