#-------------------------------------------------------------------------------
#
# Copyright 2013-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'yaml'

require 'testup/api'
require 'testup/arguments_parser'
require 'testup/defer'

module TestUp
  module App

    def self.process_arguments
      options = ArgumentsParser.parse.arguments
      return if options.empty?
      self.ci_run(options[:ci_suite_path]) if options[:ci_suite_path]
      self.ci_run_with_config(options[:ci_config_path]) if options[:ci_config_path]
    end

    def self.ci_run(test_suite, config = {})
      Execution.delay(1.0) do
        API.run_suite_without_gui(test_suite, config)
        self.quit
      end
    end

    def self.ci_run_with_config(ci_config_path)
      config = YAML.load_file(ci_config_path)
      self.ci_run(config['Path'], config)
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
