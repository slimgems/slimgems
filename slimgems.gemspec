if defined?(Gem) && !defined?(Gem::NAME)
  # Remove outer gem environment so we can re-require 'rubygems'
  $LOADED_FEATURES.delete_if {|x| x =~ /rubygems/ }
  $:.unshift(File.dirname(__FILE__) + '/lib')
  Gem.constants.each {|c| begin; Gem.send(:remove_const, c.to_sym); rescue Exception; end }
  module Gem::QuickLoader; def self.remove; end end
end
require 'rubygems'

Gem::Specification.new do |s|
  s.name          = 'slimgems'
  s.summary       = 'SlimGems is a package management framework for Ruby'
  s.description   = File.read('README')
  s.version       = Gem::VERSION
  s.authors       = ['Jim Weirich', 'Chad Fowler', 'Eric Hodel', 'Loren Segal']
  s.email         = "lsegal@soen.ca"
  s.homepage      = "http://rubygems.org"
  s.platform      = Gem::Platform::RUBY
  s.files         = Dir.glob("{bin,bootstrap,hide_lib_for_update,lib,test}/**/*") + 
                    Dir.glob('*.{rdoc,txt,rb}') + 
                    ['README', 'Rakefile', 'ChangeLog']
  s.require_paths = ['hide_lib_for_update']
  s.executables   = ['update_slimgems']
  s.extensions    = ['bootstrap/Rakefile']
  s.test_files    = Dir.glob('test/**/*.rb')
  s.required_ruby_version = '> 1.8.3'
  s.add_runtime_dependency 'rake'
end
