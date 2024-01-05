#-------------------------------------------------------------------------------
#
# Copyright 2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'testup/editor'
require 'testup/settings'

module TestUp

  testup_tests_path = File.join(__dir__, '..', '..', 'tests')
  test_suite_paths = []
  if defined?(Sketchup)
    test_suite_paths = [
      File.expand_path(File.join(testup_tests_path, 'TestUp')),
      File.expand_path(File.join(testup_tests_path, 'TestUp UI Tests')),
      File.expand_path(File.join(testup_tests_path, 'SketchUp Ruby API'))
    ]
  end
  defaults = {
    editor_application: Editor.get_default[0],
    editor_arguments: Editor.get_default[1],
    seed: nil,
    run_in_gui: defined?(Sketchup),
    verbose_console_tests: true,
    paths_to_testsuites: test_suite_paths
  }

  class << self
    attr_reader :settings
  end

  @settings = Settings.new(PLUGIN_ID, defaults)

end # module
