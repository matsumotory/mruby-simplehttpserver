config = {
  :server_ip => "0.0.0.0",
  :port  =>  8000,
  :document_root => "./",
}

server = SimpleHttpServer.new config

# /mruby location config
server.location "/mruby" do |r|
  if r.method == "POST"
    server.response_body = "Hello mruby World. Your post is '#{r.body}'\n"
  else
    server.response_body = "Hello mruby World at '#{r.path}'\n"
  end
  server.create_response
end

# /mruby/ruby location config
server.location "/mruby/ruby" do |r|
  server.set_response_headers ["Server: mruby-simplehttpserver"]
  server.response_body = "Hello mruby World. longest matche.\n"
  server.create_response
end

# /notfound location config
server.location "/notfound" do |r|
  server.set_response_headers ["Server: mruby-simplehttpserver"]
  server.response_body = "Not Found on this server: #{r.path}\n"
  server.create_response "HTTP/1.0 404 Not Found"
end

server.run
