class App
  def self.call(env)
    code = 200
    headers = { 'Server' => 'mruby-simplehttpserver' }
    path = env['PATH_INFO']
    method = env['REQUEST_METHOD']
    body = nil

    puts "Request: #{method} #{path}"

    case path
    when '/'
      body = "Hello mruby World.\n"
    when '/raise'
      # Custom error response message
      body = "This is error: #{path}\n"
      code = 503
    else
      body = "Not Found on this server: #{path}\n"
      code = 404
    end

    [code, headers, [body]]
  end
end

SimpleHttpServer.new(
  path: '/tmp/myserver.sock',
  debug: true,
  app: App,
).tap{|srv| puts("Server is running: #{srv}") }.run
