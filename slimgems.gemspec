contents = File.read(File.dirname(__FILE__) + '/lib/rubygems.rb')
eval "module ::PACKAGE\n#{contents}\nend"

Gem::Specification.new do |s|
  s.name          = PACKAGE::Gem::GEM_NAME
  s.summary       = "#{PACKAGE::Gem::NAME} is a package management framework for Ruby"
  s.description   = <<-eof
SlimGems is a drop-in replacement for RubyGems, a package management framework 
for Ruby. This project was forked at 1.3.7, which was a great stable release.

SlimGems focuses on maintaining a sane and stable API. We believe that the
project has been put through enough stress testing by the community to lock
into the current API functionality for the forseeable future. We will also
continue to improve the runtime performance over time; we can do this
without changing the API.
eof
  s.post_install_message = "Upgraded from RubyGems to #{PACKAGE::Gem::NAME} #{PACKAGE::Gem::VERSION}\n" + 
    File.open('History.txt') {|io| (io.gets('===') + io.gets('==='))[0...-3] }
  s.version       = PACKAGE::Gem::VERSION
  s.authors       = ['Jim Weirich', 'Chad Fowler', 'Eric Hodel', 'Loren Segal']
  s.email         = "lsegal@soen.ca"
  s.homepage      = "http://slimgems.github.com"
  s.platform      = Gem::Platform::RUBY
  s.files         = Dir.glob("{bin,bootstrap,hide_lib_for_update,lib,test}/**/*") + 
                    Dir.glob('*.{rdoc,txt,rb}') + 
                    ['README.md', 'Rakefile', 'ChangeLog']
  s.require_paths = ['hide_lib_for_update']
  s.executables   = ["update_#{PACKAGE::Gem::GEM_NAME}"]
  s.extensions    = ['bootstrap/Rakefile']
  s.test_files    = Dir.glob('test/**/*.rb')
  s.required_ruby_version = '> 1.8.3'
end
