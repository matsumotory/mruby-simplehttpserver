class TCPServer
  def accept
    BasicSocket.for_fd(sysaccept)
  end
end

class SimpleHttpServer
  SEP          = "\r\n".freeze
  RECV_BUF     = 1024
  HTTP_VERSION = 'HTTP/1.1'.freeze
  HTTP_DATE    = 'Date'.freeze
  ROOT_PATH    = '/'.freeze

  # Every standard HTTP code mapped to the appropriate message.
  HTTP_STATUS_CODES = {
    100 => 'Continue'.freeze,
    101 => 'Switching Protocols'.freeze,
    102 => 'Processing'.freeze,
    200 => 'OK'.freeze,
    201 => 'Created'.freeze,
    202 => 'Accepted'.freeze,
    203 => 'Non-Authoritative Information'.freeze,
    204 => 'No Content'.freeze,
    205 => 'Reset Content'.freeze,
    206 => 'Partial Content'.freeze,
    207 => 'Multi-Status'.freeze,
    208 => 'Already Reported'.freeze,
    226 => 'IM Used'.freeze,
    300 => 'Multiple Choices'.freeze,
    301 => 'Moved Permanently'.freeze,
    302 => 'Found'.freeze,
    303 => 'See Other'.freeze,
    304 => 'Not Modified'.freeze,
    305 => 'Use Proxy'.freeze,
    307 => 'Temporary Redirect'.freeze,
    308 => 'Permanent Redirect'.freeze,
    400 => 'Bad Request'.freeze,
    401 => 'Unauthorized'.freeze,
    402 => 'Payment Required'.freeze,
    403 => 'Forbidden'.freeze,
    404 => 'Not Found'.freeze,
    405 => 'Method Not Allowed'.freeze,
    406 => 'Not Acceptable'.freeze,
    407 => 'Proxy Authentication Required'.freeze,
    408 => 'Request Timeout'.freeze,
    409 => 'Conflict'.freeze,
    410 => 'Gone'.freeze,
    411 => 'Length Required'.freeze,
    412 => 'Precondition Failed'.freeze,
    413 => 'Payload Too Large'.freeze,
    414 => 'URI Too Long'.freeze,
    415 => 'Unsupported Media Type'.freeze,
    416 => 'Range Not Satisfiable'.freeze,
    417 => 'Expectation Failed'.freeze,
    421 => 'Misdirected Request'.freeze,
    422 => 'Unprocessable Entity'.freeze,
    423 => 'Locked'.freeze,
    424 => 'Failed Dependency'.freeze,
    426 => 'Upgrade Required'.freeze,
    428 => 'Precondition Required'.freeze,
    429 => 'Too Many Requests'.freeze,
    431 => 'Request Header Fields Too Large'.freeze,
    451 => 'Unavailable for Legal Reasons'.freeze,
    500 => 'Internal Server Error'.freeze,
    501 => 'Not Implemented'.freeze,
    502 => 'Bad Gateway'.freeze,
    503 => 'Service Unavailable'.freeze,
    504 => 'Gateway Timeout'.freeze,
    505 => 'HTTP Version Not Supported'.freeze,
    506 => 'Variant Also Negotiates'.freeze,
    507 => 'Insufficient Storage'.freeze,
    508 => 'Loop Detected'.freeze,
    510 => 'Not Extended'.freeze,
    511 => 'Network Authentication Required'.freeze
  }.freeze

  def self.status_line(code = 200)
    "#{HTTP_VERSION} #{code} #{HTTP_STATUS_CODES[code]}"
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
    headers[HTTP_DATE] ||= http_date

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
