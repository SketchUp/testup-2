#-------------------------------------------------------------------------------
#
# Copyright 2014, Trimble Navigation Limited
#
# This software is provided as an example of using the Ruby interface
# to SketchUp.
#
# Permission to use, copy, modify, and distribute this software for
# any purpose and without fee is hereby granted, provided that the above
# copyright notice appear in all copies.
#
# THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
#
#-------------------------------------------------------------------------------


require 'SKUI/core.rb'


module TestUp


  PATH_IMAGES     = File.join(PATH, 'images').freeze
  PATH_JS_SCRIPTS = File.join(PATH, 'js').freeze


  require File.join(PATH, 'test_window.rb')


  ### UI ### -------------------------------------------------------------------

  unless file_loaded?(__FILE__)
    # Commands
    cmd = UI::Command.new('TestUp 2') {
      self.open_testup
    }
    cmd.tooltip = 'Open TestUp'
    cmd.status_bar_text = 'Open TestUp for running tests.'
    cmd.small_icon = File.join(PATH_IMAGES, 'bug.png')
    cmd.large_icon = File.join(PATH_IMAGES, 'bug.png')
    cmd_open_testup = cmd

    # Commands
    cmd = UI::Command.new('Reload TestUp') {
      SKETCHUP_CONSOLE.clear
      window_visible = @window && @window.visible?
      @window.close if window_visible
      @window = nil
      self.open_testup if window_visible
      puts "Reloaded #{self.reload} files!"
    }
    cmd.small_icon = File.join(PATH_IMAGES, 'arrow_refresh.png')
    cmd.large_icon = File.join(PATH_IMAGES, 'arrow_refresh.png')
    cmd_reload_testup = cmd

    cmd = UI::Command.new('Run Tests') {
      self.run_tests
    }
    cmd.tooltip = 'Discover and run all tests.'
    cmd.status_bar_text = 'Discover and run all tests.'
    cmd_run_tests = cmd

    # Menus
    menu = UI.menu('Plugins').add_submenu(PLUGIN_NAME)
    menu.add_item(cmd_open_testup)
    menu.add_separator
    menu.add_item(cmd_run_tests)
    menu.add_separator
    menu.add_item(cmd_reload_testup)

    # Toolbar
    toolbar = UI::Toolbar.new(PLUGIN_NAME)
    toolbar.add_item(cmd_open_testup)
    toolbar.add_separator
    toolbar.add_item(cmd_reload_testup)
    toolbar.restore
  end


  SKETCHUP_CONSOLE.show # DEBUG


  @paths_to_testsuites = [
    File.join(__dir__, '..', '..', 'tests') # TODO: Make configurable.
  ]
  def self.paths_to_testsuites; @paths_to_testsuites; end


  ### Extension ### ------------------------------------------------------------

  def self.open_testup
    @window ||= TestUpWindow.new
    @window.show
  end


  def self.run_tests
    testsuites = self.discover_testsuites(@paths_to_testsuites)
    puts '-' * 40
    for testsuite, testcases in testsuites
      puts "#{testsuite} (#{testcases.size} test cases)"
      for testcase, tests in testcases
        puts "* #{testcase} (#{tests.size} tests)"
        puts "  * #{tests.join("\n  * ")}"
      end
    end
    puts '-' * 40
    nil
  end


  def self.discover_testsuites(test_suite_paths)
    testcase_files = self.discover_testcase_source_files(test_suite_paths)
    testsuites = {}
    for testcase_file in testcase_files
      testcase = self.load_testcase(testcase_file)
      next if testcase.nil?
      next if testcase.test_methods.empty?
      suitename = self.get_testcase_suitename(testcase_file)
      testsuites[suitename] ||= {}
      testsuites[suitename][testcase] = testcase.test_methods
    end
    testsuites
  end


  def self.get_testcase_suitename(testcase_filename)
    path = File.expand_path(testcase_filename)
    parts = path.split(File::SEPARATOR)
    testcase_file = File.basename(testcase_filename)
    testcase_name = File.basename(testcase_filename, '.*')
    # The TC_*.rb file might be wrapped in a TC_* folder. The suite name is the
    # parent of either one of these.
    index = parts.index(testcase_name) || parts.index(testcase_file)
    parts[index - 1]
  end


  # @param [Array<String>] test_suite_paths
  # @return [Array<String>] Path to all TC_*.rb files found.
  def self.discover_testcase_source_files(test_suite_paths)
    all_testcase_files = []
    for test_suite_path in test_suite_paths
      testcase_filter = File.join(test_suite_path, '*/TC_*.rb')
      testcases = Dir.glob(testcase_filter)
      all_testcase_files.concat(testcases)
    end
    all_testcase_files
  end


  # @param [String] testcase_file
  # @return [Object|Nil] The TestUp::TestCase object.
  def self.load_testcase(testcase_file)
    testcase_name = File.basename(testcase_file, '.*')
    self.remove_old_tests(testcase_name.intern)
    begin
      load testcase_file
    rescue ScriptError
      raise #TODO
      return nil
    end
    testcase = Object.const_get(testcase_name.intern)
    unless testcase.ancestors.include?(TestUp::TestCase)
      # (?) raise error?
      warn "Invalid testcase: #{testcase} (#{testcase.ancestors.inspect})"
    end
    testcase
  end


  # @param [Symbol] testcase
  # @return [Nil]
  def self.remove_old_tests(testcase)
    if Object.constants.include?(testcase)
      Object.send(:remove_const, testcase)
    end
    nil
  end


  ### DEBUG ### ----------------------------------------------------------------

  # TestUp.reload
  def self.reload
    original_verbose = $VERBOSE
    $VERBOSE = nil
    filter = File.join(PATH, '*.{rb,rbs}')
    files = Dir.glob(filter).each { |file|
      load file
    }
    files.length
  ensure
    $VERBOSE = original_verbose
  end

end # module

#-------------------------------------------------------------------------------

file_loaded(__FILE__)

#-------------------------------------------------------------------------------
