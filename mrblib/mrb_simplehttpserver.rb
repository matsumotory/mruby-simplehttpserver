class TCPServer
  def accept
    BasicSocket.for_fd(self.sysaccept)
  end
end

class SimpleHttpServer
  def initialize config
    @config = config
    @host = config[:server_ip]
    @port = config[:port] 
    @docroot = config[:document_root]
    @locconf = {}
    
    @req = nil
    @res = nil
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

  def get_response socket, req
    body = "Hello mruby-simplehttpserver World.\n"
    res = "HTTP/1.0 200 OK\r\nContent-Length: #{body.size}\r\n\r\n#{body}"
    socket.send res, 0
  end

  def error_response socket
    body = "Service Unavailable\n"
    headers = ["Content-Length: #{body.size}"]
    err = "HTTP/1.0 503 Service Unavailable\r\n#{headers.join "\r\n"}\r\n\r\n"
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
