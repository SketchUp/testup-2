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


# Third party dependencies.

# TODO(thomthom): Install minitest if it's missing.
require 'rubygems'
gem 'minitest'
require 'minitest'

# TODO(thomthom): Embed SKUI into project.
require 'SKUI/core.rb'


module TestUp

  ### Constants ### ------------------------------------------------------------

  SKETCHUP_CONSOLE.show # DEBUG

  PATH_IMAGES     = File.join(PATH, 'images').freeze
  PATH_JS_SCRIPTS = File.join(PATH, 'js').freeze

  # TEMP constant.
  PATH_OLD_TESTUP = 'C:/src/thomthom-su2014-pc/src/googleclient/sketchup/source/testing/testup'.freeze


  ### Dependencies ### ---------------------------------------------------------

  require File.join(PATH, 'compatibility.rb')
  require File.join(PATH, 'debug.rb')
  require File.join(PATH, 'sketchup_console.rb')
  require File.join(PATH, 'test_window.rb')
  require File.join(PATH, 'ui.rb')


  ### UI ### -------------------------------------------------------------------

  self.init_ui


  ### Configuration ### --------------------------------------------------------

  @run_in_gui = false

  # TODO: Make configurable.
  @paths_to_testsuites = [
    File.join(__dir__, '..', '..', 'tests'),
    File.join(ENV['HOME'], 'SourceTree', 'SUbD', 'Ruby', 'tests'),
    File.join(PATH_OLD_TESTUP, 'tests')
  ]


  class << self
    attr_accessor :paths_to_testsuites
    attr_accessor :run_in_gui
    attr_accessor :window
  end


  ### Extension ### ------------------------------------------------------------

  def self.open_testup
    @window ||= TestUpWindow.new
    @window.show
  end


  def self.run_tests
    unless @window && @window.visible?
      warn 'TestUp window not open.'
      UI.beep
      return
    end
    unless self.run_in_gui
      SKETCHUP_CONSOLE.show
      SKETCHUP_CONSOLE.clear
    end
    self.discover_testsuites(@paths_to_testsuites)
    testsuite = @window.bridge.call('$(".tab.selected").text')
    tests = @window.bridge.call('TestUp.selected_tests')
    puts "Running test suite: #{testsuite}"
    arguments = []
    arguments << "-n /^(#{tests.join('|')})$/"
    arguments << '--verbose' if true
    arguments << '--testup' if self.run_in_gui
    MiniTest.run(arguments)
  end


  def self.display_minitest_help
    SKETCHUP_CONSOLE.show
    MiniTest.run(['--help'])
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
    existing_test_classes = self.all_test_classes
    begin
      load testcase_file
    rescue ScriptError => error
      warn "ScriptError Loading #{testcase_name}"
      warn self.format_load_backtrace(error)
      return nil
    rescue StandardError => error
      warn "StandardError Loading #{testcase_name}"
      warn self.format_load_backtrace(error)
      return nil
    end
    new_test_classes = self.all_test_classes - existing_test_classes
    if new_test_classes.empty?
      warn "'#{testcase_name}' - No test cases loaded."
      #warn existing_test_classes.sort{|a,b|a.name<=>b.name}.join("\n")
      return nil
    elsif new_test_classes.size > 1
      warn "'#{testcase_name}' - More than one test class loaded: #{new_test_classes.join(', ')}"
      return nil
    end
    #testcase = Object.const_get(testcase_name.intern)
    testcase = new_test_classes.first
    unless testcase.ancestors.include?(TestUp::TestCase)
      #warn "Invalid testcase: #{testcase} (#{testcase.ancestors.inspect})"
      testcase.extend(TestCaseExtendable)
    end
    testcase
  end


  def self.format_load_backtrace(error)
    file_basename = File.basename(__FILE__)
    index = error.backtrace.index { |line|
      line =~ /testup\/#{file_basename}:\d+:in `load'/i
    }
    filtered_backtrace = error.backtrace[0..index]
    error.message << "\n" << filtered_backtrace.join("\n")
  end


  def self.all_test_classes
    klasses = []
    ObjectSpace.each_object(Class){ |klass|
      klasses << klass if klass.name =~ /^TC_/
    }
    klasses
  end


  # Remove the old testcase class so changes can be made without reloading
  # SketchUp. This is done because MiniTest is made to be run as a traditional
  # Ruby script on a web server where the lifespan of objects isn't persistent
  # as it is in SketchUp.
  #
  # TODO(thomthom): It might be better to remove all loaded tests in a separate
  # pass. Currently if a test is renamed it won't be removed and will keep
  # running since the discoverer only removes old tests if it overwrites them.
  #
  # @param [Symbol] testcase
  # @return [Nil]
  def self.remove_old_tests(testcase)
    if Object.constants.include?(testcase)
      Object.send(:remove_const, testcase)
      # Remove any previously loaded versions from MiniTest. Otherwise MiniTest
      # will keep running them along with the new ones.
      MiniTest::Runnable.runnables.delete_if { |klass|
        klass.to_s == testcase.to_s
      }
    end
    nil
  end

end # module

#-------------------------------------------------------------------------------

file_loaded(__FILE__)

#-------------------------------------------------------------------------------
