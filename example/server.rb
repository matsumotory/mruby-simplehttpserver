# 
# Server Configration
# 

server = SimpleHttpServer.new({

  :server_ip => "0.0.0.0",
  :port  =>  8000,

  # not implemented 
  :document_root => "./",
})


#
# HTTP Initialize Configuration Per Request
#

server.http do 
  server.set_response_headers ["Server: my-mruby-simplehttpserver"]
  server.set_response_headers ["Date: #{server.http_date}"]
end

# 
# Location Configration
# 

# You can use request parameters in location
#   r.method
#   r.schema
#   r.host
#   r.port
#   r.path
#   r.query
#   r.body

# /mruby location config
server.location "/mruby" do |r|
  if r.method == "POST"
    server.response_body = "Hello mruby World. Your post is '#{r.body}'\n"
  else
    server.response_body = "Hello mruby World at '#{r.path}'\n"
  end
  server.create_response
end

# /mruby/ruby location config, location config longest match
server.location "/mruby/ruby" do |r|
  server.response_body = "Hello mruby World. longest matche.\n"
  server.create_response
end

server.location "/html" do |r|
  server.set_response_headers ["Content-Type: text/html; charset=utf-8"]
  # or server.response_headers << ["Content-Type: text/html; charset=utf-8"]
  server.response_body = "<H1>Hello mruby World.</H1>\n"
  server.create_response
end

# Custom error response message
server.location "/notfound" do |r|
  server.response_body = "Not Found on this server: #{r.path}\n"
  server.create_response "HTTP/1.0 404 Not Found"
end

server.run
