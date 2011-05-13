# -*- ruby -*-

$:.unshift 'lib'

require 'rubygems'
require 'rubygems/package_task'
require 'rake/testtask'

desc "Run just the functional tests"
Rake::TestTask.new(:test_functional) do |t|
  t.test_files = FileList['test/functional*.rb']
end

Rake::TestTask.new(:test) do |t|
  t.test_files = FileList['test/test_*.rb']
end

# These tasks expect to have the following directory structure:
#
#   git/git.rubini.us/code # Rubinius git HEAD checkout
#   svn/ruby/trunk         # ruby subversion HEAD checkout
#   svn/rubygems/trunk     # RubyGems subversion HEAD checkout
#
# If you don't have this directory structure, set RUBY_PATH and/or
# RUBINIUS_PATH.

def rsync_with dir
  rsync_options = "-avP --exclude '*svn*' --exclude '*swp' --exclude '*rbc'" +
    " --exclude '*.rej' --exclude '*.orig' --exclude 'lib/rubygems/defaults/*'"
  sh "rsync #{rsync_options} bin/gem             #{dir}/bin/gem"
  sh "rsync #{rsync_options} lib/                #{dir}/lib"
  sh "rsync #{rsync_options} test/               #{dir}/test/rubygems"
  sh "rsync #{rsync_options} util/gem_prelude.rb #{dir}/gem_prelude.rb"
end

def diff_with dir
  diff_options = "-urpN --exclude '*svn*' --exclude '*swp' --exclude '*rbc'"
  sh "diff #{diff_options} bin/gem             #{dir}/bin/gem;         true"
  sh "diff #{diff_options} lib/ubygems.rb      #{dir}/lib/ubygems.rb;  true"
  sh "diff #{diff_options} lib/rubygems.rb     #{dir}/lib/rubygems.rb; true"
  sh "diff #{diff_options} lib/rubygems        #{dir}/lib/rubygems;    true"
  sh "diff #{diff_options} lib/rbconfig        #{dir}/lib/rbconfig;    true"
  sh "diff #{diff_options} test                #{dir}/test/rubygems;   true"
  sh "diff #{diff_options} util/gem_prelude.rb #{dir}/gem_prelude.rb;  true"
end

rubinius_dir = ENV['RUBINIUS_PATH'] || '../../../git/git.rubini.us/code'
ruby_dir     = ENV['RUBY_PATH']     || '../../ruby/trunk'

desc "Updates Ruby HEAD with the currently checked-out copy of RubyGems."
task :update_ruby do
  rsync_with ruby_dir
end

desc "Updates Rubinius HEAD with the currently checked-out copy of RubyGems."
task :update_rubinius do
  rsync_with rubinius_dir
end

desc "Diffs Ruby HEAD with the currently checked-out copy of RubyGems."
task :diff_ruby do
  diff_with ruby_dir
end

desc "Diffs Rubinius HEAD with the currently checked-out copy of RubyGems."
task :diff_rubinius do
  diff_with rubinius_dir
end

desc "Get coverage for a specific test, no system RubyGems."
task "rcov:for", [:test] do |task, args|
  mgem  = Gem.source_index.find_name("minitest").first rescue nil
  rgem  = Gem.source_index.find_name(/rcov/).first
  libs  = rgem.require_paths.map { |p| File.join rgem.full_gem_path, p }
  rcov  = File.join rgem.full_gem_path, rgem.bindir, rgem.default_executable

  if mgem
    libs << mgem.require_paths.map { |p| File.join mgem.full_gem_path, p }
  end

  libs << "lib:test"

  flags  = []
  flags << "-I" << libs.flatten.join(":")

  rflags  = []
  rflags << "-i" << "lib/rubygems"

  ruby "#{flags.join ' '} #{rcov} #{rflags.join ' '} #{args[:test]}"
end

task :graph do
  $: << File.expand_path("~/Work/p4/zss/src/graph/dev/lib")
  require 'graph'
  deps = Graph.new
  deps.rotate

  current = nil
  `rake -P -s`.each_line do |line|
    case line
    when /^rake (.+)/
      current = $1
      deps[current] if current # force the node to exist, in case of a leaf
    when /^\s+(.+)/
      deps[current] << $1 if current
    else
      warn "unparsed: #{line.chomp}"
    end
  end


  deps.boxes
  deps.save "graph", nil
end

