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
    body = "<H1>Hello mruby World.</H1>\n"
  when '/notfound'
    # Custom error response message
    body = "Not Found on this server: #{path}\n"
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
