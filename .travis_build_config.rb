MRuby::Build.new do |conf|
  toolchain :gcc
  conf.gembox 'default'
  conf.gem :github => 'iij/mruby-io'
  conf.gem :github => 'iij/mruby-socket'
  conf.gem :github => 'mattn/mruby-http'
  conf.gem '../mruby-simplehttpserver'
end
