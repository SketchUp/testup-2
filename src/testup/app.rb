#-------------------------------------------------------------------------------
#
# Copyright 2013-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'yaml'

require 'testup/api'
require 'testup/app_files'
require 'testup/arguments_parser'
require 'testup/defer'

module TestUp
  module App

    extend AppFiles

    def self.process_arguments
      options = ArgumentsParser.parse.arguments
      return if options.empty?
      self.ci_run(options[:ci_suite_path]) if options[:ci_suite_path]
      self.ci_run_with_config(options[:ci_config_path]) if options[:ci_config_path]
    end

    # @param [String] test_suite Path to the Test Suite to run.
    # @param [Hash] config
    def self.ci_run(test_suite, config = {})
      Execution.delay(1.0) do
        API.run_suite_without_gui(test_suite, config)
        self.quit unless config['KeepOpen']
      end
    end

    # @param [String] ci_config_path Path to the configuration file to run.
    def self.ci_run_with_config(ci_config_path)
      config = self.read_config_file(ci_config_path)
      self.log_path = config['LogPath'] if config.key?('LogPath')
      self.saved_runs_path = config['SavedRunsPath'] if config.key?('SavedRunsPath')
      self.ci_run(config['Path'], config)
    end

    # @param [String] ci_config_path Path to the configuration file to parse.
    def self.read_config_file(ci_config_path)
      config = YAML.load_file(ci_config_path)
      config_dir = File.dirname(ci_config_path)
      # Expand config variables.
      ['Path', 'Output', 'LogPath', 'SavedRunsPath'].each { |key|
        value = config[key]
        next unless value.is_a?(String)

        value.gsub!('%CONFIG_DIR%', config_dir)
      }
      config
    end

    def self.quit
      # Discard any model changes from the tests running, so we can exit
      # SketchUp without any dialog prompts.
      Sketchup.active_model.close(true)

      Execution.delay(1.0) do
        # Seems to get an Access Violation otherwise.
        Sketchup.quit
      end
    end

  end
end # module TestUp
