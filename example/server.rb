config = {
  :server_ip => "0.0.0.0",
  :port  =>  8000,
  :document_root => "./",
}

server = SimpleHttpServer.new config

# /mruby location config
server.location "/mruby" do |req|
  if req.method == "POST"
    server.response_body = "Hello mruby World. Your post is '#{req.body}'\n"
  else
    server.response_body = "Hello mruby World at '#{req.path}'\n"
  end
  server.create_response
end

# /mruby/ruby location config
server.location "/mruby/ruby" do |req|
  server.set_response_headers ["Server: mruby-simplehttpserver"]
  server.response_body = "Hello mruby World. longest matche.\n"
  server.create_response
end

# /notfound location config
server.location "/notfound" do |req|
  server.set_response_headers ["Server: mruby-simplehttpserver"]
  server.response_body = "Not Found on this server: #{req.path}\n"
  server.create_response "HTTP/1.0 404 Not Found"
end

server.run
