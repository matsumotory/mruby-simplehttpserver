class TCPServer
  def accept
    BasicSocket.for_fd(self.sysaccept)
  end
end

class SimpleHttpServer
  SEP = "\r\n"
  attr_accessor :response_body
  def initialize config
    @config = config
    @host = config[:server_ip]
    @port = config[:port] 
    @docroot = config[:document_root]
    @locconf = {}
    
    @req = nil
    @res = nil
    @response_headers = []
    @response_body = nil
  end

  def run
    server = TCPServer.new @host, @port
    while true
      conn = server.accept
      begin
        data = ''
        while true 
          buf = conn.recv(1024)
          data << buf
          break if buf.size != 1024
        end
        @req = HTTP::Parser.new.parse_request data
        @response_headers = []
        @response_body = nil

        # checking location config
        key = check_location(@req.path)

        unless key.nil?
          response = @locconf[key].call @req
          conn.send response, 0
        else
          if @req.method == "GET"
            get_response conn, @req
          elsif @req.method == "POST"
            #post_response conn, @req
            error_response conn
          else
            error_response conn
          end
        end
      ensure
        conn.close
      end
    end
  end

  def set_response_headers response_headers
    @response_headers << response_headers
  end

  def create_response
    set_response_headers ["Content-Length: #{@response_body.size}"]
    "HTTP/1.0 200 OK" + SEP + @response_headers.join("\r\n") + SEP * 2 + @response_body
  end

  def get_response socket, req
    @response_body = "Hello mruby-simplehttpserver World.\n"
    socket.send create_response, 0
  end

  def error_response socket
    body = "Service Unavailable\n"
    set_response_headers ["Content-Length: #{body.size}"]
    err = "HTTP/1.0 503 Service Unavailable" + SEP + @response_headers.join("\r\n") + SEP * 2
    socket.send "#{err}#{body}", 0
  end

  def location url, &blk
    @locconf[url] = blk
  end

  def check_location path
    locations = @locconf.keys.sort{|a, b| b.size <=> a.size}
    locations.each do |key|
      if path.index(key) == 0
        return key
      end
    end
    nil
  end
end
