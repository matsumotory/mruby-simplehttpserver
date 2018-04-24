class TCPServer
  def accept
    BasicSocket.for_fd(sysaccept)
  end
end

class SimpleHttpServer
  SEP          = "\r\n".freeze
  RECV_BUF     = 1024
  HTTP_VERSION = 'HTTP/1.1'.freeze
  ROOT_PATH    = '/'.freeze

  def self.status_line(code = 200)
    "#{HTTP_VERSION} #{code} #{Shelf::Utils::HTTP_STATUS_CODES[code]}"
  end

  def initialize(config)
    @config   = config
    @host     = config[:server_ip]
    @port     = config[:port]
    @nonblock = config[:nonblock] != false
    @timeout  = config[:timeout] || 5
    @app      = config[:app]
    @parser   = HTTP::Parser.new
  end

  attr_reader :config, :host, :port

  def run
    server = TCPServer.new(host, port)

    loop do
      sock = server.accept

      begin
        data = receive_data(sock)
        res  = on_data(data) if data
        sock.send(res, 0)    if res
      rescue
        raise 'Connection reset by peer' if config[:debug] && sock.closed?
      ensure
        sock.close rescue nil
      end
    end
  end

  def receive_data(sock)
    data = ''
    time = Time.now if @nonblock

    loop do
      begin
        data << buf = sock.recv(RECV_BUF, @nonblock ? Socket::MSG_DONTWAIT : 0)
        return data if buf.size != RECV_BUF
      rescue
        next if (Time.now - time) < @timeout
      end
    end
  end

  def on_data(data)
    request               = @parser.parse_request(data)
    env                   = request_to_env(request)
    status, headers, body = @app.call(env)

    create_response(status, headers, body.join(''))
  end

  def request_to_env(req)
    req.headers.merge(
      'REQUEST_METHOD' => req.method,
      'PATH_INFO'      => req.path || ROOT_PATH,
      'QUERY_STRING'   => req.query,
      'HTTP_VERSION'   => HTTP_VERSION
    )
  end

  def create_response(code, headers, body)
    headers[Shelf::DATE] ||= http_date

    header_ary = []
    headers.each { |k, v| header_ary << ["#{k}:#{v}"] if v }

    SimpleHttpServer.status_line(code) + SEP \
    + header_ary.join(SEP) + SEP + SEP \
    + body
  end

  def http_date
    tp = Time.now.gmtime.to_s.split
    "#{tp[0]}, #{tp[2]} #{tp[1]} #{tp[5]} #{tp[3]} GMT"
  end
end
