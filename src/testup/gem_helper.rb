#-------------------------------------------------------------------------------
#
# Copyright 2013-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

module TestUp
  module GemHelper

    # @param [String] gem_name
    # @param [String] filename
    # @param [Gem::Requirement] version
    def self.require(gem_name, filename, version: Gem::Requirement.default)
      # puts "GemHelper.require(#{gem_name}, #{filename}, #{version})"
      Kernel.require 'rubygems'
      begin
        # puts "> Try activating gem..."
        gem gem_name, version
      rescue Gem::LoadError
        puts "Installing Gem: #{gem_name} (Please wait...)"
        begin
          self.install(gem_name, version)
        rescue Gem::LoadError # rubocop:disable Lint/HandleExceptions
          # Needed because of Ruby 2.2. Ruby 2.0 did not need this. Seems like
          # a bug. This pattern is probably not that common, to be
          # programmatically installing gems.
        end
        # puts "> Try activating installed gem..."
        gem gem_name, version
      end
      # puts "> Loading gem..."
      Kernel.require filename
    end

    # @return [String]
    def self.local_copy
      File.join(__dir__, 'gems')
    end

    # @return [Array<String>]
    def self.local_gems
      pattern = File.join(self.local_copy, '*.gem')
      Dir.glob(pattern).to_a
    end

    # @param [String] gem_name
    # @param [Gem::Requirement, String] gem_version
    # @return [String, nil]
    def self.find_local_copy(gem_name, gem_version)
      self.local_gems.find { |gem_file|
        basename = File.basename(gem_file)
        name, version = basename.match(/^(.+)-([^-]+)\.gem$/).captures
        gem_name.casecmp(name).zero? && gem_version.to_s.casecmp(version).zero?
      }
    end

    # @param [String] gem_name
    # @param [Gem::Requirement] version
    def self.install(gem_name, version = Gem::Requirement.default)
      local_path = self.find_local_copy(gem_name, version)
      if local_path
        puts '> Installing from local copy...'
        puts "> #{local_path}"
        Gem.install(local_path)
      else
        puts '> Installing from Ruby Gems...'
        Gem.install(gem_name, version)
      end
    end

  end
end # module TestUp
