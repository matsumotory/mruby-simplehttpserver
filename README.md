# mruby-simplehttpserver   [![Build Status](https://travis-ci.org/matsumoto-r/mruby-simplehttpserver.png?branch=master)](https://travis-ci.org/matsumoto-r/mruby-simplehttpserver)
SimpleHttpServer class
## install by mrbgems 
- add conf.gem line to `build_config.rb` 

```ruby
MRuby::Build.new do |conf|

    # ... (snip) ...

    conf.gem :github => 'iij/mruby-io'
    conf.gem :github => 'iij/mruby-socket'
    conf.gem :github => 'mattn/mruby-http'
    conf.gem :github => 'matsumoto-r/mruby-simplehttpserver'
end
```
## example 
```ruby
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

server.run
```

## License
under the MIT License:
- see LICENSE file
