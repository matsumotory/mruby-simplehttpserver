##
## SimpleHttpServer Test
##

## Setup configuration
host = 'localhost'
port = 8000
app = Proc.new do |env|
  code = 200
  headers = { 'Server' => 'mruby-simplehttpserver' }
  path = env['PATH_INFO']
  method = env['REQUEST_METHOD']
  body = nil

  case path
  when '/mruby'
    body = "Hello mruby World.\n"
  when '/html'
    headers['Content-type'] = 'text/html; charset=utf-8'
    body = '<H1>Hello mruby World.</H1>'
  when '/notfound'
    # Custom error response message
    body = "Not Found on this server: #{path}"
    code = 404
  end

  [code, headers, [body]]
end

assert 'SimpleHttpServer#initialize' do
  server = SimpleHttpServer.new(server_ip: host, port: port, app: app)

  assert_kind_of Hash, server.config
  assert_equal host, server.host
  assert_equal port, server.port
end

assert 'SimpleHttpServer#config' do
  server = SimpleHttpServer.new(server_ip: host, port: port, app: app)

  assert_include server.config, :server_ip
  assert_kind_of String, server.config[:server_ip]
  assert_equal host, server.config[:server_ip]

  assert_include server.config, :port
  assert_kind_of Integer, server.config[:port]
  assert_equal port, server.config[:port]

  assert_include server.config, :app
  assert_equal app, server.config[:app]

  assert_not_include server.config, :nonblock
  assert_nil server.config[:nonblock]

  # Update configuration
  server.config[:nonblock] = true

  assert_include server.config, :nonblock
  assert_true server.config[:nonblock]
end

assert 'SimpleHttpServer#run' do
  server = SimpleHttpServer.new(server_ip: host, port: port, app: app)
  pid = fork { server.run }

  h = HTTP::Parser.new()

  res = `curl -si localhost:8000/mruby`
  h.parse_response(res) {|x|
    assert_equal 'GET', x.method
    assert_equal 'mruby-simplehttpserver', x.headers['Server']
    assert_nil x.headers['Content-type']
    assert_equal "Hello mruby World.\n", x.body
  }

  res = `curl -si localhost:8000/html`
  h.parse_response(res) {|x|
    assert_equal 'text/html; charset=utf-8', x.headers['Content-type']
    assert_equal "<H1>Hello mruby World.</H1>", x.body
  }

  res = `curl -si localhost:8000/notfound`
  h.parse_response(res) {|x|
    assert_equal 'Not Found on this server: /notfound', x.body
  }

  Process.kill :TERM, pid
end
