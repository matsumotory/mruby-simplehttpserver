MRuby::Gem::Specification.new('mruby-simplehttpserver') do |spec|
  spec.license = 'MIT'
  spec.authors = 'MATSUMOTO Ryosuke'
  spec.version = '0.0.1'
  spec.add_dependency('mruby-tiny-io')
  spec.add_dependency('mruby-socket')
  spec.add_dependency('mruby-http')
end
