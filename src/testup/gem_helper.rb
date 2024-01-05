#-------------------------------------------------------------------------------
#
# Copyright 2013-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

module TestUp

  module GemHelper

    # Requires a gem, and installs it as needed.
    #
    # If a version is specified, a matching gem of `version` or higher will be
    # activated if it is already installed.  The exact version will be installed otherwise.
    #
    # If no version is specified, the most recent version will be installed.
    #
    # @param [String] gem_name
    # @param [String] filename
    # @param [String, nil] version
    def self.require(gem_name, filename, version: nil)
      Kernel.require 'rubygems'

      # restrict to major value of `version`
      requirement = version ? "~> #{version[/\A\d+\.\d+/]}" : ">= 0"

      begin
        gem gem_name, requirement
      rescue Gem::LoadError
        puts "Installing Gem: #{gem_name} (Please wait...)"
        begin
          self.install(gem_name, version)
        rescue Gem::LoadError
        end
        gem gem_name, requirement
      end
      Kernel.require filename
    end

    # @param [String] gem_name
    # @param [String, nil] gem_version
    # @return [String, nil] the full path to the gem file
    def self.find_local_copy(gem_name, gem_version)
      Dir["#{__dir__}/gems/*.gem"].find { |gem_file|
        basename = File.basename(gem_file, '.gem')
        name, _, version = basename.rpartition '-'
        gem_name.casecmp(name).zero? && gem_version.to_s.casecmp(version).zero?
      }
    end

    # @param [String] gem_name
    # @param [String] version
    def self.install(gem_name, version = nil)
      local_path = self.find_local_copy(gem_name, version)
      if local_path
        puts '> Installing from local copy...'
        puts "> #{local_path}"
        Gem.install(local_path, nil, {domain: :local})
        puts "> Installed #{gem_name}-#{version}"
      else
        puts '> Installing from rubygems.org...'
        version ||= Gem::Requirement.default
        Gem.install(gem_name, version)
      end
    end

  end
end # module TestUp
