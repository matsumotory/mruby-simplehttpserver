# MIT License
#
# Copyright (c) MATSUMOTO Ryosuke 2014
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Represents a TCP/IP server socket who delegates the requests to a shelf app.
class SimpleHttpServer
  SEP          = "\r\n".freeze
  RECV_BUF     = 1024
  HTTP_VERSION = 'HTTP/1.1'.freeze
  ROOT_PATH    = '/'.freeze

  # Initializes the server via a config hash map.
  #
  # @param [ Hash<Symbol, Object> ] config Required are :host, :port and :app
  #
  # @return [ Void ]
  def initialize(config)
    @config   = config
    @host     = config[:host] || config[:server_ip]
    @port     = config[:port]
    @path     = config[:path]
    @nonblock = config[:nonblock] != false
    @timeout  = [0, config[:timeout] || 5].max
    @app      = config[:app]
    @parser   = HTTP::Parser.new
  end

  attr_reader :config, :host, :port, :path

  # Bind to the host and port and wait for incomming connections.
  #
  # @return [ Void ]
  def run
    srv = if self.path
            UNIXServer.new(path)
          else
            TCPServer.new(host, port)
          end

    loop do
      io = accept_connection(srv)

      begin
        data = receive_data(io)
        send_data(io, handle_data(io, data)) if data
      rescue
        raise 'Connection reset by peer' if config[:debug] && io.closed?
      ensure
        io.close rescue nil
        GC.start if config[:run_gc_per_request]
      end
    end
  end

  private

  # Wait for incoming socket connection.
  #
  # @param [ TCPServer ] tcp The TCP server which is bind to a port.
  #
  # @return [ BasicSocket ]
  def accept_connection(tcp)
    counter = counter ? counter + 1 : 1

    sock = BasicSocket.for_fd(tcp.sysaccept)
    sock.setsockopt(Socket::SOL_SOCKET, Socket::SO_NOSIGPIPE, true) if Socket.const_defined? :SO_NOSIGPIPE
    sock
  rescue RuntimeError => e
    counter == 1 ? retry : raise(e)
  end

  # Receive data from the socket in a loop until all data have been received.
  # Might break out of the loop in case of a timeout.
  #
  # @param [ BasicSocket ] io The tcp socket from where to read the data.
  #
  # @return [ String ] nil if no data could be read.
  def receive_data(io)
    data = nil
    time = Time.now if @nonblock
    ext  = String.method_defined? :<<

    loop do
      begin
        buf = io.recv(RECV_BUF, @nonblock ? Socket::MSG_DONTWAIT : 0)

        if !data
          data = buf
        elsif ext
          data << buf
        else
          data += buf
        end

        return data if buf.size != RECV_BUF
      rescue
        next if (Time.now - time) < @timeout
      end
    end
  end

  # Parse the HTTP request to pass the env to the shelf app
  # and return the HTTP response string.
  #
  # @param [ BasicSocket ] io   The tcp socket from where to read the data.
  # @param [ String ]      data The data reveiced from the socket.
  #
  # @return [ String ]
  def handle_data(io, data)
    request              = @parser.parse_request(data)
    env                  = request_to_env(request)
    status, header, body = @app.call(env)

    create_response(status, header, body.join)
  end

  # Send data back to the client.
  #
  # @param [ BasicSocket ] io   The tcp socket where to send the data.
  # @param [ String ]      data The data to send.
  #
  # @return [ String ]
  def send_data(io, data)
    loop do
      n = io.syswrite(data)
      return if n == data.bytesize
      data = data[n..-1]
    end
  end

  # Convert the parsed HTTP request into an environemt hash
  # to be passed to the shelf app.
  #
  # @param [ HTTP::Request ] req The parsed HTTP request object.
  #
  # @return [ Hash<String, Object> ]
  def request_to_env(req)
    string_io = StringIO.new
    string_io.write req.body
    string_io.rewind

    req.headers.merge(
      Shelf::REQUEST_METHOD   => req.method,
      Shelf::PATH_INFO        => req.path || ROOT_PATH,
      Shelf::QUERY_STRING     => req.query,
      Shelf::HTTP_VERSION     => HTTP_VERSION,
      Shelf::SERVER_NAME      => 'mruby-simplehttpserver',
      Shelf::SERVER_ADDR      => host,
      Shelf::SERVER_PORT      => port,
      Shelf::SHELF_URL_SCHEME => req.schema,
      Shelf::SHELF_INPUT      => string_io
    )
  end

  # Convert the response returned by @app.call into a HTTP response.
  # https://www.w3.org/Protocols/rfc2616/rfc2616-sec6.html
  #
  # @param [ Fixnum ]               code   The HTTP status code.
  # @param [ Hash<String, String> ] header The header as a key-value list.
  # @param [ String ]               body   The message body.
  #
  # @return [ String ]
  def create_response(code, header, body)
    header[:Date] ||= http_date
    header[:Connection] = :close

    header_ary = []
    header.each { |k, v| header_ary << ["#{k}:#{v}"] if v }

    http_status_line(code) + SEP \
    + header_ary.join(SEP) + SEP + SEP \
    + body
  end

  # Return the HTTP status line including the HTTP version, response code
  # and short description.
  #
  # @param [ Fixnum ] code The HTTP status code.
  #                        Defaults to: 200 (OK)
  #
  # @return [ String ]
  def http_status_line(code = 200)
    "#{HTTP_VERSION} #{code} #{Shelf::Utils::HTTP_STATUS_CODES[code]}"
  end

  # The date and time at which the message was originated.
  # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Date
  #
  # @return [ String ]
  def http_date
    tp = Time.now.gmtime.to_s.split
    "#{tp[0]}, #{tp[2]} #{tp[1]} #{tp[5]} #{tp[3]} GMT"
  end
end
