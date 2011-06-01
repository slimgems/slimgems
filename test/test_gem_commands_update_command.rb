require File.expand_path('../gemutilities', __FILE__)
require 'rubygems/commands/update_command'

class TestGemCommandsUpdateCommand < RubyGemTestCase

  def setup
    super
    
    @oldpath = Dir.pwd
    Dir.chdir(File.dirname(__FILE__))

    @cmd = Gem::Commands::UpdateCommand.new

    @cmd.options[:generate_rdoc] = false
    @cmd.options[:generate_ri]   = false

    util_setup_fake_fetcher
    util_setup_spec_fetcher @a1, @a2, @a3a

    @a1_path = File.join @gemhome, 'cache', @a1.file_name
    @a2_path = File.join @gemhome, 'cache', @a2.file_name
    @a3a_path = File.join @gemhome, 'cache', @a3a.file_name

    @fetcher.data["#{@gem_repo}gems/#{@a1.file_name}"] =
      read_binary @a1_path
    @fetcher.data["#{@gem_repo}gems/#{@a2.file_name}"] =
      read_binary @a2_path
    @fetcher.data["#{@gem_repo}gems/#{@a3a.file_name}"] =
      read_binary @a3a_path
  end
  
  def teardown
    super
    Dir.chdir(@oldpath)
  end
  
  def test_execute
    util_clear_gems

    Gem::Installer.new(@a1_path).install

    @cmd.options[:args] = []
    @cmd.options[:generate_rdoc] = true
    @cmd.options[:generate_ri]   = true

    use_ui @ui do
      @cmd.execute
    end

    out = @ui.output.split "\n"
    assert_match "Updating installed gems", out.shift
    assert_match "Updating #{@a2.name}", out.shift
    assert_match "Successfully installed #{@a2.full_name}", out.shift
    assert_match "Gems updated: #{@a2.name}", out.shift
    assert_match "Installing ri documentation for a-2...", out.join
    assert_match "Installing RDoc documentation for a-2...", out.join
  end

  def util_setup_rubygem version
    gem = quick_gem(Gem::GEM_NAME, version.to_s) do |s|
      s.files = %w[setup.rb]
    end
    write_file File.join(*%W[gems #{gem.original_name} setup.rb])
    util_build_gem gem
    util_setup_spec_fetcher gem
    gem
  end

  def util_setup_rubygem8
    @rubygem8 = util_setup_rubygem 8
  end

  def util_setup_rubygem9
    @rubygem9 = util_setup_rubygem 9
  end

  def util_setup_rubygem_current
    @rubygem_current = util_setup_rubygem Gem::VERSION
  end

  def util_add_to_fetcher *specs
    specs.each do |spec|
      gem_file = File.join @gemhome, 'cache', spec.file_name

      @fetcher.data["http://gems.example.com/gems/#{spec.file_name}"] =
        Gem.read_binary gem_file
    end
  end

  def test_execute_system
    util_setup_rubygem9
    util_setup_spec_fetcher @rubygem9
    util_add_to_fetcher @rubygem9
    util_clear_gems

    @cmd.options[:args]          = []
    @cmd.options[:system]        = true
    @cmd.options[:generate_rdoc] = false
    @cmd.options[:generate_ri]   = false

    use_ui @ui do
      @cmd.execute
    end

    out = @ui.output.split "\n"
    assert_equal "Updating #{Gem::GEM_NAME}", out.shift
    assert_equal "Successfully installed #{Gem::GEM_NAME}-9", out.shift
    assert_equal "#{Gem::NAME} system software updated (9)", out.shift

    assert_empty out
  end

  def test_execute_system_at_latest
    util_setup_rubygem_current
    util_setup_spec_fetcher @rubygem_current
    util_add_to_fetcher @rubygem_current
    util_clear_gems

    @cmd.options[:args]          = []
    @cmd.options[:system]        = true
    @cmd.options[:generate_rdoc] = false
    @cmd.options[:generate_ri]   = false

    assert_raises Gem::SystemExitException do
      use_ui @ui do
        @cmd.execute
      end
    end

    out = @ui.output.split "\n"
    assert_equal "#{Gem::NAME} is already up-to-date (#{Gem::VERSION})", out.shift
    assert_empty out
  end

  def test_execute_system_multiple
    util_setup_rubygem9
    util_setup_rubygem8
    util_setup_spec_fetcher @rubygem8, @rubygem9
    util_add_to_fetcher @rubygem8, @rubygem9
    util_clear_gems

    @cmd.options[:args]          = []
    @cmd.options[:system]        = true
    @cmd.options[:generate_rdoc] = false
    @cmd.options[:generate_ri]   = false

    use_ui @ui do
      @cmd.execute
    end

    out = @ui.output.split "\n"
    assert_equal "Updating #{Gem::GEM_NAME}", out.shift
    assert_equal "Successfully installed #{Gem::GEM_NAME}-9", out.shift
    assert_equal "#{Gem::NAME} system software updated (9)", out.shift

    assert_empty out
  end

  def test_execute_system_specific
    util_clear_gems
    util_setup_rubygem9
    util_setup_rubygem8
    util_setup_spec_fetcher @rubygem8, @rubygem9
    util_add_to_fetcher @rubygem8, @rubygem9

    @cmd.options[:args]          = []
    @cmd.options[:system]        = "8"
    @cmd.options[:generate_rdoc] = false
    @cmd.options[:generate_ri]   = false

    use_ui @ui do
      @cmd.execute
    end

    out = @ui.output.split "\n"
    assert_equal "Updating #{Gem::GEM_NAME}", out.shift
    assert_equal "Successfully installed #{Gem::GEM_NAME}-8", out.shift
    assert_equal "#{Gem::NAME} system software updated (8)", out.shift

    assert_empty out
  end

  def test_execute_system_with_gems
    @cmd.options[:args]          = %w[gem]
    @cmd.options[:system]        = true
    @cmd.options[:generate_rdoc] = false
    @cmd.options[:generate_ri]   = false

    assert_raises MockGemUi::TermError do
      use_ui @ui do
        @cmd.execute
      end
    end

    assert_empty @ui.output
    assert_equal "ERROR:  Gem names are not allowed with the --system option\n",
                 @ui.error
  end

  # before:
  #   a1 -> c1.2
  # after:
  #   a2 -> b2 # new dependency
  #   a2 -> c2

  def test_execute_dependencies
    @a1.add_dependency 'c', '1.2'

    @c2 = quick_gem 'c', '2' do |s|
      s.files = %w[lib/code.rb]
      s.require_paths = %w[lib]
    end

    @a2.add_dependency 'c', '2'
    @a2.add_dependency 'b', '2'

    @b2_path   = File.join @gemhome, 'cache', @b2.file_name
    @c1_2_path = File.join @gemhome, 'cache', @c1_2.file_name
    @c2_path   = File.join @gemhome, 'cache', @c2.file_name

    @source_index = Gem::SourceIndex.new
    @source_index.add_spec @a1
    @source_index.add_spec @a2
    @source_index.add_spec @b2
    @source_index.add_spec @c1_2
    @source_index.add_spec @c2

    util_build_gem @a1
    util_build_gem @a2
    util_build_gem @c2

    @fetcher.data["#{@gem_repo}gems/#{@a1.file_name}"] = read_binary @a1_path
    @fetcher.data["#{@gem_repo}gems/#{@a2.file_name}"] = read_binary @a2_path
    @fetcher.data["#{@gem_repo}gems/#{@b2.file_name}"] = read_binary @b2_path
    @fetcher.data["#{@gem_repo}gems/#{@c1_2.file_name}"] =
      read_binary @c1_2_path
    @fetcher.data["#{@gem_repo}gems/#{@c2.file_name}"] = read_binary @c2_path

    util_setup_spec_fetcher @a1, @a2, @b2, @c1_2, @c2
    util_clear_gems

    Gem::Installer.new(@c1_2_path).install
    Gem::Installer.new(@a1_path).install

    @cmd.options[:args] = []

    use_ui @ui do
      @cmd.execute
    end

    out = @ui.output.split "\n"
    assert_equal "Updating installed gems", out.shift
    assert_equal "Updating #{@a2.name}", out.shift
    assert_equal "Successfully installed #{@c2.full_name}", out.shift
    assert_equal "Successfully installed #{@b2.full_name}", out.shift
    assert_equal "Successfully installed #{@a2.full_name}", out.shift
    assert_equal "Gems updated: #{@c2.name}, #{@b2.name}, #{@a2.name}",
                 out.shift

    assert_empty out
  end

  def test_execute_named
    util_clear_gems

    Gem::Installer.new(@a1_path).install

    @cmd.options[:args] = [@a1.name]

    use_ui @ui do
      @cmd.execute
    end

    out = @ui.output.split "\n"
    assert_equal "Updating installed gems", out.shift
    assert_equal "Updating #{@a2.name}", out.shift
    assert_equal "Successfully installed #{@a2.full_name}", out.shift
    assert_equal "Gems updated: #{@a2.name}", out.shift

    assert_empty out
  end

  def test_execute_named_up_to_date
    util_clear_gems

    Gem::Installer.new(@a2_path).install

    @cmd.options[:args] = [@a2.name]

    use_ui @ui do
      @cmd.execute
    end

    out = @ui.output.split "\n"
    assert_equal "Updating installed gems", out.shift
    assert_equal "Nothing to update", out.shift

    assert_empty out
  end

  def test_execute_named_up_to_date_prerelease
    util_clear_gems

    Gem::Installer.new(@a2_path).install

    @cmd.options[:args] = [@a2.name]
    @cmd.options[:prerelease] = true

    use_ui @ui do
      @cmd.execute
    end

    out = @ui.output.split "\n"
    assert_equal "Updating installed gems", out.shift
    assert_equal "Updating #{@a3a.name}", out.shift
    assert_equal "Successfully installed #{@a3a.full_name}", out.shift
    assert_equal "Gems updated: #{@a3a.name}", out.shift

    assert_empty out
  end

  def test_execute_up_to_date
    util_clear_gems

    Gem::Installer.new(@a2_path).install

    @cmd.options[:args] = []

    use_ui @ui do
      @cmd.execute
    end

    out = @ui.output.split "\n"
    assert_equal "Updating installed gems", out.shift
    assert_equal "Nothing to update", out.shift

    assert_empty out
  end

  def test_handle_options_system
    @cmd.handle_options %w[--system]

    expected = {
      :generate_ri   => true,
      :system        => true,
      :force         => false,
      :args          => [],
      :generate_rdoc => true,
      :test          => false,
    }

    assert_equal expected, @cmd.options
  end

  def test_handle_options_system_non_version
    assert_raises ArgumentError do
      @cmd.handle_options %w[--system non-version]
    end
  end

  def test_handle_options_system_specific
    @cmd.handle_options %w[--system 1.3.7]

    expected = {
      :generate_ri   => true,
      :system        => "1.3.7",
      :force         => false,
      :args          => [],
      :generate_rdoc => true,
      :test          => false,
    }

    assert_equal expected, @cmd.options
  end

end
