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

$twitter_bot

#setup
configure do
  set :server, 'thin'
  enable :sessions
  set :session_secret, "My session secret"
  use OmniAuth::Builder do
    #I know this bad form but I haven't deployed yet. So Shhhhhhhh
    provider :twitter, 'p2xojaAqxCshYaAraH4otANCr', 'TKzK7CRkr71oLRa102V6DF5VQY5BAltvqrkHZWxhXouybcNAxZ'
    provider :github, '5394720ddae7b4107128', '17ce0361111c4eaf2746e89de451aa0bc804951a'
  end
  $twitter_bot = Twitter::REST::Client.new do |config|
    config.consumer_key        = "p2xojaAqxCshYaAraH4otANCr"
    config.consumer_secret     = "TKzK7CRkr71oLRa102V6DF5VQY5BAltvqrkHZWxhXouybcNAxZ"
    config.access_token        = "2391713136-Plaxgd57076XBXN4F9Cq3SfR3bxj6o1ZlZEICAS"
    config.access_token_secret = "WYKbsT8HyIt4pC38Y8ggo3tT1EYe0Fq7ZVfrTtsxZYubA"
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
  $twiitter_bot = client
  "#{env['omniauth.auth']}<br><br>#{env['omniauth.auth'][:credentials][:token]}<br>#{env['omniauth.auth'][:credentials][:secret]}<br>#{env['omniauth.auth'][:uid]}"
  erb :registered
end

get '/auth/failure' do
  params[:message]
end

get '/logout' do
  session[:admin] = nil
  "You are now logged out"
end

get '/blog' do
  erb :blog
end

post '/register' do
    @u = User.new
    @u.name = params[:user_name]
    @u.github_path = params[:github_path]
    @u.save
    @r = Repo.new
    @r.github_path = @u.github_path
    @r.lines = 0
    response = HTTParty.get('https://api.github.com/repos/honeycodedbear/gitter/commits?client_id=5394720ddae7b4107128&client_secret=96a96f7a666b4dfa0708a881c56edac9c702dbb0', headers: {"User-Agent" => 'Git Twit', "Accept" => "application/vnd.github.v3+json"})
    json = JSON.parse(response.body)
    @r.last_sha = json[0]["sha"]
    @r.save
    erb :registered
end

get '/' do
  erb :index
end

get "/meta_data" do
  erb :meta_data
end

#Working Thread

#Compare commits
#curl "https://api.github.com/repos/honeycodedbear/gitter/compare/aa5a8bd2c5f5b648ab84344ee3fe90457a3dbb25...b8262a36c765127924b5c424005a695fde02298c"
#Could read through the number of lines there are and also get the file extension.
#Then we could collect meta data on languages/frameworks this way
#Look for +numbers's. This be an easy way to find the data. Then I should be able to look at all of the file extensions and give it loads of fun data.
#Get commits per hour
#RestClient.get("https://api.github.com/repos/honeycodedbear/gitter/stats/punch_card")

#Using git api compare
#response = HTTParty.get("https://api.github.com/repos/honeycodedbear/gitter/compare/aa5a8bd2c5f5b648ab84344ee3fe90457a3dbb25...b8262a36c765127924b5c424005a695fde02298c")
#json = JSON.parse(repsonse.body)
#json["files"][i]["filename"]
#json["files"][i]["additions"]

#returns a string. Example "Ruby"
def what_language? filename
  test = filename.partition(".").last
  case test
  when "rb", "ru", "erb", "slim", "haml"
    "Ruby"
  when "py"
    "Python"
  when "java", "jsp", "jsf"
    "Java"
  when "cpp"
    "C++"
  when "m"
    "Obj-C"
  when "c"
    "C"
  when "js", "coffee"
    "Javascript"
  when "html"
    "Html"
  when "cs"
    "C#"
  when "css", "scss", "less"
    "CSS"
  when "php"
    "PHP"
  when "md"
    "Readme"
  when "hs"
    "Haskell"
  when "pm", "pl"
    "Perl"
  when ".sh"
    "Bash/Shell"
  else
    "Other"
  end
end

def reload_server
  client_id = '5394720ddae7b4107128'
  client_secret = '96a96f7a666b4dfa0708a881c56edac9c702dbb0'
  api_path = 'https://api.github.com/repos/'
  str = ""
  #r = Repo.last
  #FINALLY GOT THIS TO WORK!!!! PRAISE CAT GOD!!!
  #curl -i 'https://api.github.com/repos/honeycodedbear/gitter/compare/aa5a8bd2c5f5b648ab84344ee3fe90457a3dbb25...b8262a36c765127924b5c424005a695fde02298c?client_id=5394720ddae7b4107128&client_secret=96a96f7a666b4dfa0708a881c56edac9c702dbb0'
  #NOTE TO SELF, RERUN/SHOTGUN FUCK UP SESSION_COOKIE, GIT NO LIKELY
  #response = HTTParty.get("https://api.github.com/repos/honeycodedbear/gitter/compare/aa5a8bd2c5f5b648ab84344ee3fe90457a3dbb25...b8262a36c765127924b5c424005a695fde02298c?client_id=5394720ddae7b4107128&client_secret=96a96f7a666b4dfa0708a881c56edac9c702dbb0", headers: {"User-Agent" => 'Git Twit', "Accept" => "application/vnd.github.v3+json"})
  Repo.all.each do |r|
    repo_path = r.github_path.partition("https://github.com/").last
    path = "#{api_path}#{repo_path}/commits?client_id=#{client_id}&client_secret=#{client_secret}"
    #str += "#{path}<br>"
    #str += "https://api.github.com/repos/honeycodedbear/gitter/commits?client_id=5394720ddae7b4107128&client_secret=96a96f7a666b4dfa0708a881c56edac9c702dbb0 <br>"
    response = HTTParty.get(path, headers: {"User-Agent" => 'Git Twit', "Accept" => "application/vnd.github.v3+json"})
    json = JSON.parse(response.body)
    latest_sha = json[0]["sha"]
    if r.last_sha == latest_sha
      str += "#{r.github_path} is up to date <br><br>"
    else
      path = "#{api_path}#{repo_path}/compare/#{r.last_sha}...#{latest_sha}?client_id=#{client_id}&client_secret=#{client_secret}"
      str += "#{path} <br><br>"
      response = HTTParty.get(path, headers: {"User-Agent" => 'Git Twit', "Accept" => "application/vnd.github.v3+json"})
      json = JSON.parse(response.body)
      r.last_sha = latest_sha
      r.save
      str += "#{json['files']}<br><br>"
      #try stringify when you get back
      if json["files"]
        #str += "#{json['files']}<br><br>"
        Language.update_all(hourly_count: 0)
        json["files"].each do |f|
          lang = Language.where(name: what_language?("#{f["filename"]}")).first
          lang.number_of_lines += f["additions"]
          lang.hourly_count += f["additions"]
          str += "#{lang.name} : #{lang.hourly_count} : #{lang.number_of_lines} <br>"
          lang.save
        end
        tweet = "TEST: Max has written "
        Language.where("hourly_count > 0").find_each.with_index do |l, index|
          tweet += "#{l.hourly_count} lines in #{l.name}; "
        end
        tweet += "in the last hour"
        $twitter_bot.update(tweet)
        str += "#{tweet}<br><br>"
        puts "MAKE A THING"
      else
        str += "json is empty <br><br>"
      end
    end
  end
  str
end

get "/reload_server" do
  reload_server
end

#THIS WORKS
#curl -i 'https://api.github.com/repos/honeycodedbear/gitter/compare/aa5a8bd2c5f5b648ab84344ee3fe90457a3dbb25...b8262a36c765127924b5c424005a695fde02298c?client_id=5394720ddae7b4107128&client_secret=96a96f7a666b4dfa0708a881c56edac9c702dbb0'
