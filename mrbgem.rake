MRuby::Gem::Specification.new('mruby-simplehttpserver') do |spec|
  spec.license = 'MIT'
  spec.authors = 'MATSUMOTO Ryosuke'
  spec.version = '0.0.1'

  spec.add_dependency('mruby-string-ext', core: 'mruby-string-ext')
  spec.add_dependency('mruby-time', core: 'mruby-time')
  spec.add_dependency('mruby-socket')
  spec.add_dependency('mruby-http')
  spec.add_dependency('mruby-io')
end
