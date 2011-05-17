# SlimGems

* Website: http://slimgems.github.com/
* Github: http://github.com/slimgems/slimgems
* Get gems from: http://rubygems.org

## Description

SlimGems is a drop-in replacement for RubyGems, a package management framework 
for Ruby. We forked the project at 1.3.7, which was a great stable release.

SlimGems focuses on maintaining a sane and stable API. We believe that the
project has been put through enough stress testing by the community to lock
into the current API functionality for the forseeable future. We will also
continue to improve the runtime performance over time; we can do this
without changing the API.

## Project Goals

1. A fast package manager that "Just Works". We will attempt to make SlimGems
   as fast as possible and believe it can be done without breaking the existing
   API.
   
2. A consistent and stable API. Deprecations will not occur without ample
   warning to library developers *before* a release. Deprecations will not 
   necessarily mean removed methods or runtime warnings, and we will consult 
   with the community if widely used APIs ever need to be removed.
   
3. Receptive and friendly project maintainers. We will listen to your bugs
   and suggestions without deriding you. We believe the community deserves
   a voice in matters that affect package management tools, and we respect 
   that voice.

4. Improved communication with the community about future plans. We believe
   it's important to keep the community informed about major changes. We will
   discuss our rationale for any changes that might cause problems for other
   library developers.

## What Do I Have to do Differently to Use SlimGems?

Nothing. We maintain the same install paths, APIs and overall runtime environment
that RubyGems had. The only difference is that we have no intention on changing
this environment in future upgrades. You can upgrade safely knowing that the
newer versions of SlimGems will still be compatible with all of your code.

In short, yes, "require 'rubygems'" still works.

## Installing and Upgrading

If you're on RubyGems, you can easily upgrade to SlimGems by typing:

    $ gem install slimgems
  
You can do this from SlimGems too, but if you have SlimGems already, upgrading
works better with:

    $ gem update --system

If you don't have any RubyGems or SlimGems install, there is still the pre-gem 
approach to getting software, doing it manually:

1. Download from: http://github.com/slimgems/slimgems
2. Unpack into a directory and cd there
3. Install with: ruby setup.rb  # you may need admin/root privilege

For more details and other options, see:

    ruby setup.rb --help

## Uninstalling

If SlimGems isn't for you, you can downgrade back to RubyGems by performing
the following commands:

    $ gem install rubygems-update
    $ rubygems_update

Again, you might need to have administrator privileges (sudo) to run these
commands.

## Notes about this SlimGems Fork

SlimGems is a RubyGems fork of RubyGems 1.3.7 and a limited set of backports
from 1.5.2. SlimGems is maintained by Loren Segal and others. SlimGems will
provide continual improvements with a stable API.

You can download the original RubyGems project at 
http://rubyforge.org/projects/rubygems
