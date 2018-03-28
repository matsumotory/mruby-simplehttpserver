# mruby-simplehttpserver   [![Build Status](https://travis-ci.org/matsumotory/mruby-simplehttpserver.svg?branch=master)](https://travis-ci.org/matsumotory/mruby-simplehttpserver)

mruby-simplehttpserver is a HTTP Server with less dependency for mruby. mruby-simplehttpserver depends on mruby-io, mruby-socket and mruby-http. A Web server using mruby-simplehttpserver run on a environment which is not very rich like [OSv](http://osv.io/) or simple Linux box.

### Install by mrbgems

add conf.gem line to `build_config.rb`:

```ruby
MRuby::Build.new do |conf|

    # ... (snip) ...

    conf.gem mgem: 'mruby-simplehttpserver'
end
```

## How to use SimpleHttpServer

SimpleHttpServer class provides a HTTP Server.

SimpleHttpServer has a [Rack](http://rack.github.io/)-like interface, so you should provide an "app": an object that responds to `#call`, taking the environment hash as a parameter, and returning an Array with three elements:

- HTTP Status Code
- Headers hash
- Body

#### Example: a simple "OK" server

The following example code can be used as the basis of a HTTP Server which returning "OK":

```ruby
app = -> (env) { [200, { 'Content-Type' => 'text/plain' }, ['OK']] }

server = SimpleHttpServer.new(
  server_ip: 'localhost',
  port: 8000,
  app: app,
)

server.run
```

`SimpleHttpServer#run` invokes a server that returns "OK". (If you want to stop the server, enter `^C` key.) You can see its response with curl:

```console
$ curl localhost:8000
OK
```

If you see more examples, see [example/server.rb](https://github.com/matsumoto-r/mruby-simplehttpserver/blob/master/example/server.rb).

#### What does `env` receive?

`env`, which an "app" takes as a parameter, receives a hash object includes request headers and the following parameters:

- REQUEST\_METHOD ... GET, PUT, POST, DELETE and so on.
- PATH\_INFO ... request path or '/'
- QUERY\_STRING ... query string
- HTTP\_VERSION ... 'HTTP/1.1'

If you want to see how to parse an request, see also [mattn/mruby-http](https://github.com/mattn/mruby-http).

Public Instance Methods
---

### run()

A process requests on sock.

## License

under the MIT License:

- see [LICENSE](./LICENSE) file
