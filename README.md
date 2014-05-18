# mruby-simplehttpserver   [![Build Status](https://travis-ci.org/matsumoto-r/mruby-simplehttpserver.png?branch=master)](https://travis-ci.org/matsumoto-r/mruby-simplehttpserver)
SimpleHttpServer class
## install by mrbgems 
- add conf.gem line to `build_config.rb` 

```ruby
MRuby::Build.new do |conf|

    # ... (snip) ...

    conf.gem :github => 'matsumoto-r/mruby-simplehttpserver'
    conf.gem :github => 'iij/mruby-io'
    conf.gem :github => 'iij/mruby-socket'
end
```
## example 
```ruby
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
```

## License
under the MIT License:
- see LICENSE file
