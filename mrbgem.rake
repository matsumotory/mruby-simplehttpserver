require "#{MRUBY_ROOT}/lib/mruby/source"

MRuby::Gem::Specification.new('mruby-simplehttpserver') do |spec|
  spec.license = 'MIT'
  spec.authors = ['MATSUMOTO Ryosuke', 'KATZER Sebastian']
  spec.version = '1.0.0'

  spec.add_dependency('mruby-string-ext', core: 'mruby-string-ext')
  spec.add_dependency('mruby-time', core: 'mruby-time')
  spec.add_dependency('mruby-http')

  if MRuby::Source::MRUBY_VERSION >= '1.4.0'
    spec.add_dependency('mruby-io', core: 'mruby-io')
    spec.add_dependency('mruby-socket', core: 'mruby-socket')
  else
    spec.add_dependency('mruby-io')
    spec.add_dependency('mruby-socket')
  end
end
