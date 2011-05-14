contents = File.read(File.dirname(__FILE__) + '/lib/rubygems.rb')
eval "module ::PACKAGE\n#{contents}\nend"

Gem::Specification.new do |s|
  s.name          = 'slimgems'
  s.summary       = 'SlimGems is a package management framework for Ruby'
  s.description   = File.read('README.md')
  s.post_install_message = "Upgraded from RubyGems to #{PACKAGE::Gem::NAME} #{PACKAGE::Gem::VERSION}\n" + 
    File.open('History.txt') {|io| (io.gets('===') + io.gets('==='))[0...-3] }
  s.version       = PACKAGE::Gem::VERSION
  s.authors       = ['Jim Weirich', 'Chad Fowler', 'Eric Hodel', 'Loren Segal']
  s.email         = "lsegal@soen.ca"
  s.homepage      = "http://rubygems.org"
  s.platform      = Gem::Platform::RUBY
  s.files         = Dir.glob("{bin,bootstrap,hide_lib_for_update,lib,test}/**/*") + 
                    Dir.glob('*.{rdoc,txt,rb}') + 
                    ['README.md', 'Rakefile', 'ChangeLog']
  s.require_paths = ['hide_lib_for_update']
  s.executables   = ['update_slimgems']
  s.extensions    = ['bootstrap/Rakefile']
  s.test_files    = Dir.glob('test/**/*.rb')
  s.required_ruby_version = '> 1.8.3'
  s.add_runtime_dependency 'rake'
end
