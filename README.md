# mruby-simplehttpserver   [![Build Status](https://travis-ci.org/matsumoto-r/mruby-simplehttpserver.svg?branch=master)](https://travis-ci.org/matsumoto-r/mruby-simplehttpserver)

mruby-simplehttpserver is a HTTP Server with less dependency for mruby. mruby-simplehttpserver depends on mruby-io, mruby-socket and mruby-http. A Web server using mruby-simplehttpserver run on a environment which is not very rich like [OSv](http://osv.io/) or simple Linux box.

## install by mrbgems 
#### add conf.gem line to `build_config.rb` 
```ruby
MRuby::Build.new do |conf|

    # ... (snip) ...

    conf.gem :github => 'iij/mruby-io'
    conf.gem :github => 'iij/mruby-pack'
    conf.gem :github => 'iij/mruby-socket'
    conf.gem :github => 'mattn/mruby-http'
    conf.gem :github => 'matsumoto-r/mruby-simplehttpserver'
end
```
#### run mruby
```bash
./bin/mruby server.rb
```
## License
under the MIT License:
- see LICENSE file

## example server.rb
If you see more example, see [example/server.rb](https://github.com/matsumoto-r/mruby-simplehttpserver/blob/master/example/server.rb)
```ruby
# 
# Server Configration
# 

server = SimpleHttpServer.new({

  :server_ip => "0.0.0.0",
  :port  =>  8000,
  :document_root => "./",
})


#
# HTTP Initialize Configuration Per Request
#

# You can use request parameters at http or location configration
#   r.method
#   r.schema
#   r.host
#   r.port
#   r.path
#   r.query
#   r.headers
#   r.body

server.http do |r|
  server.set_response_headers({
    "Server" => "my-mruby-simplehttpserver",
    "Date" => server.http_date,
  })
end

# 
# Location Configration
# 

# /mruby location config
server.location "/mruby" do |r|
  if r.method == "POST"
    server.response_body = "Hello mruby World. Your post is '#{r.body}'\n"
  else
    server.response_body = "Hello mruby World at '#{r.path}'\n"
  end
  server.create_response
end

server.run
```
