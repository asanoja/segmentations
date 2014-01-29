require 'webrick'
include WEBrick

root = File.expand_path './www'

port="8030"
puts "Starting server: http://#{Socket.gethostname}:#{port}"
server = HTTPServer.new(:Port=>port,:DocumentRoot=>root )
trap("INT"){ server.shutdown }
server.start
