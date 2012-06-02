require 'rubygems/command'
require 'rubygems/command_manager'
require 'rubygems/install_update_options'
require 'rubygems/local_remote_options'
require 'rubygems/spec_fetcher'
require 'rubygems/version_option'
require 'rubygems/commands/install_command'

class Gem::Commands::UpdateCommand < Gem::Command

  include Gem::InstallUpdateOptions
  include Gem::LocalRemoteOptions
  include Gem::VersionOption

  def initialize
    super 'update',
          'Update the named gems (or all installed gems) in the local repository',
      :generate_rdoc => false,
      :generate_ri   => false,
      :force         => false,
      :test          => false

    add_install_update_options

    OptionParser.accept Gem::Version do |value|
      Gem::Version.new value

      value
    end

    add_option('--system [VERSION]', Gem::Version,
               "Update the #{Gem::NAME} system software") do |value, options|
      value = true unless value

      options[:system] = value
    end

    add_local_remote_options
    add_platform_option
    add_prerelease_option "as update targets"
  end

  def arguments # :nodoc:
    "GEMNAME       name of gem to update"
  end

  def defaults_str # :nodoc:
    "--no-rdoc --no-ri --no-force --no-test --install-dir #{Gem.dir}"
  end

  def usage # :nodoc:
    "#{program_name} GEMNAME [GEMNAME ...]"
  end

  def execute
    @installer = Gem::DependencyInstaller.new options
    @updated   = []

    hig = {}

    if options[:system] then
      update_rubygems
      return
    else
      say "Updating installed gems"

      hig = {} # highest installed gems

      Gem.source_index.each do |name, spec|
        if hig[spec.name].nil? or hig[spec.name].version < spec.version then
          hig[spec.name] = spec
        end
      end
    end

    gems_to_update = which_to_update hig, options[:args]

    updated = update_gems gems_to_update

    if updated.empty? then
      say "Nothing to update"
    else
      say "Gems updated: #{updated.map { |spec| spec.name }.join ', '}"

      if options[:generate_ri] then
        updated.each do |gem|
          Gem::DocManager.new(gem, options[:rdoc_args]).generate_ri
        end

        Gem::DocManager.update_ri_cache
      end

      if options[:generate_rdoc] then
        updated.each do |gem|
          Gem::DocManager.new(gem, options[:rdoc_args]).generate_rdoc
        end
      end
    end
  end

  def update_gem name, version = Gem::Requirement.default
    return if @updated.any? { |spec| spec.name == name }
    success = false

    say "Updating #{name}"
    begin
      @installer.install name, version
      success = true
    rescue Gem::InstallError => e
      alert_error "Error installing #{name}:\n\t#{e.message}"
      success = false
    end

    @installer.installed_gems.each do |spec|
      @updated << spec
      say "Successfully installed #{spec.full_name}" if success
    end
  end

  def update_gems gems_to_update
    gems_to_update.uniq.sort.each do |name|
      update_gem name
    end

    @updated
  end

  ##
  # Update SlimGems software to the latest version.

  def update_rubygems
    unless options[:args].empty? then
      alert_error "Gem names are not allowed with the --system option"
      terminate_interaction 1
    end

    options[:user_install] = false

    version = options[:system]
    if version == true then
      version     = Gem::Version.new     Gem::VERSION
      requirement = Gem::Requirement.new ">= #{Gem::VERSION}"
    else
      version     = Gem::Version.new     version
      requirement = Gem::Requirement.new version
    end

    rubygems_update         = Gem::Specification.new
    rubygems_update.name    = Gem::GEM_NAME
    rubygems_update.version = version

    hig = {
      Gem::GEM_NAME => rubygems_update
    }

    gems_to_update = which_to_update hig, options[:args]

    if gems_to_update.empty? then
      say "#{Gem::NAME} is already up-to-date (#{Gem::VERSION})"
      terminate_interaction
    end

    update_gem(gems_to_update.first, requirement)
    spec = @updated.last
    say "#{Gem::NAME} system software updated (#{spec.version})" if spec
  end

  def which_to_update(highest_installed_gems, gem_names)
    result = []

    highest_installed_gems.each do |l_name, l_spec|
      next if not gem_names.empty? and
              gem_names.all? { |name| /#{name}/ !~ l_spec.name }

      dependency = Gem::Dependency.new l_spec.name, "> #{l_spec.version}"
      dependency.prerelease = options[:prerelease]

      begin
        fetcher = Gem::SpecFetcher.fetcher
        spec_tuples = fetcher.find_matching dependency, false, true,
                                            options[:prerelease]
      rescue Gem::RemoteFetcher::FetchError => e
        raise unless fetcher.warn_legacy e do
          require 'rubygems/source_info_cache'

          dependency.name = '' if dependency.name == //

          specs = Gem::SourceInfoCache.search_with_source dependency

          spec_tuples = specs.map do |spec, source_uri|
            [[spec.name, spec.version, spec.original_platform], source_uri]
          end
        end
      end

      matching_gems = spec_tuples.select do |(name, _, platform),|
        name == l_name and Gem::Platform.match platform
      end

      highest_remote_gem = matching_gems.sort_by do |(_, version),|
        version
      end.last

      if highest_remote_gem and
         l_spec.version < highest_remote_gem.first[1] then
        result << l_name
      end
    end

    result
  end

end

