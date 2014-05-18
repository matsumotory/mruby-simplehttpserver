class TCPServer
  def accept
    BasicSocket.for_fd(self.sysaccept)
  end
end

class SimpleHttpServer
  SEP = "\r\n"
  attr_accessor :response_body, :response_headers
  def initialize config
    @config = config
    @host = config[:server_ip]
    @port = config[:port] 
    @docroot = config[:document_root]
    @httpinit = nil 
    @locconf = {}
    
    # init per request
    @r = nil
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

        # init per request
        @r = HTTP::Parser.new.parse_request data
        @response_headers = []
        @response_body = nil
        # init block called
        unless @httpinit.nil?
          @httpinit.call
        end

        # checking location config
        key = check_location(@r.path)

        unless key.nil?
          response = @locconf[key].call @r
          conn.send response, 0
        else
          # default response when can't found location config
          if @r.method == "GET"
            error_404_response conn, @r
          elsif @r.method == "POST"
            error_503_response conn
          else
            error_503_response conn
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

  def create_response status_msg=nil
    if status_msg.nil?
      status_msg = "HTTP/1.0 200 OK"
    end
    set_response_headers ["Content-Length: #{@response_body.size}"]
    status_msg + SEP + @response_headers.join("\r\n") + SEP * 2 + @response_body
  end

  def error_404_response socket, r
    set_response_headers ["Date: #{http_date}"]
    @response_body = "Not Found on this server: #{r.path}\n"
    socket.send create_response("HTTP/1.0 404 Not Found"), 0
  end

  def error_503_response socket
    set_response_headers ["Date: #{http_date}"]
    @response_body = "Service Unavailable\n"
    socket.send create_response("HTTP/1.0 503 Service Unavailable"), 0
  end

  def http &blk
    @httpinit = blk
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

  def http_date
    t = Time.new.gmtime.to_s
    tp = t.split " "
    "#{tp[0]}, #{tp[2]} #{tp[1]} #{tp[5]} #{tp[3]} GMT"
  end
end
