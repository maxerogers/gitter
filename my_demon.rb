require "HTTParty"
thr = Thread.new do
  while true
    sleep 0.12
    puts HTTParty.get("http://localhost:4567/reload_server")
  end
end
thr.join
