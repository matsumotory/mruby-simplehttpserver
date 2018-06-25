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

require "#{MRUBY_ROOT}/lib/mruby/source"

MRuby::Gem::Specification.new('mruby-simplehttpserver') do |spec|
  spec.license = 'MIT'
  spec.authors = ['MATSUMOTO Ryosuke', 'KATZER Sebastian']
  spec.version = '1.0.0'

  spec.add_dependency('mruby-time', core: 'mruby-time')
  spec.add_dependency('mruby-http')
  spec.add_dependency('mruby-shelf')

  if MRuby::Source::MRUBY_VERSION >= '1.4.0'
    spec.add_dependency('mruby-io', core: 'mruby-io')
    spec.add_dependency('mruby-socket', core: 'mruby-socket')
  else
    spec.add_dependency('mruby-io')
    spec.add_dependency('mruby-socket')
  end

  spec.add_test_dependency('mruby-process', mgem: 'mruby-process2')
end
