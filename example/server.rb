config = {                                                                       
  :server_ip => "0.0.0.0",                                                       
  :port  =>  80,                                                                 
  :document_root => "./",                                                        
}                                                                                
                                                                                 
server = SimpleHttpServer.new config                                             
                                                                                 
# /mruby location config                                                         
server.location "/mruby" do |req|                                                
  if req.method == "POST"                                                        
    "Hello mruby World. Your post is '#{req.body}'\n"                            
  else                                                                           
    "Hello mruby World at '#{req.path}'\n"                                       
  end                                                                            
end                                                                              
                                                                                 
# /mruby/ruby location config                                                    
server.location "/mruby/ruby" do |req|                                           
  "Hello mruby World. longest matche.\n"                                         
end                                                                              
                                                                                 
server.run                                                                       
