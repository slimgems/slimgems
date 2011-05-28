#--
# Copyright 2006, 2007 by Chad Fowler, Rich Kilmer, Jim Weirich, Eric Hodel
# and others.
# All rights reserved.
# See LICENSE.txt for permissions.
#++

Dir.chdir File.dirname(__FILE__)

# Make sure rubygems isn't already loaded.
if defined?(Gem)
  ENV.delete 'RUBYOPT'
  
  ENV['RUBYOPT'] = '--disable-gems' if RUBY_VERSION >= '1.9'
  ENV['GEM_BOOTSTRAP'] = 'true' unless defined?(Gem::NAME)

  require 'rbconfig'
  config = defined?(RbConfig) ? RbConfig : Config

  ruby = File.join config::CONFIG['bindir'], config::CONFIG['ruby_install_name']
  ruby << config::CONFIG['EXEEXT']

  exec(ruby, 'setup.rb', *ARGV)
end

$:.unshift 'lib'
require 'rubygems'
require 'rubygems/gem_runner'
require 'rubygems/exceptions'

Gem::CommandManager.instance.register_command :setup

args = ARGV.clone

args.unshift 'setup'

begin
  Gem::GemRunner.new.run args
rescue Gem::SystemExitException => e
  exit e.exit_code
end

