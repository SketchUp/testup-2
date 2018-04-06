#-------------------------------------------------------------------------------
#
# Copyright 2013-2014 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------


module TestUp
 class TestDiscoverer

  # Error type used when loading the .RB files containing the test cases.
  class TestCaseLoadError < StandardError
    attr_reader :original_error
    def initialize(error)
      @original_error = error
    end
  end


  attr_reader :errors


  # @param [Array<String>] paths_to_testsuites
  def initialize(paths_to_testsuites)
    @paths_to_testsuites = paths_to_testsuites
    @errors = []
  end

  # @return [Array]
  def discover
    @errors.clear
    # Reset list of runnables MiniTest knows about.
    MiniTest::Runnable.runnables.clear
    testsuites = {}
    for testsuite_path in @paths_to_testsuites
      if !File.directory?(testsuite_path)
        warn "WARNING: Not a valid directory: #{testsuite_path}"
        next
      end

      testsuite_name = File.basename(testsuite_path)
      if testsuites.key?(testsuite_name)
        # TODO: raise custom error and catch later for display in UI.
        raise "Duplicate testsuites: #{testsuite_name} - #{testsuite_path}"
      end

      testsuite = discover_testcases(testsuite_path)
      coverage = Coverage.new(testsuite_path)
      missing_tests = coverage.missing_tests(testsuite)

      testsuites[testsuite_name] = {
        :testcases => testsuite,
        :coverage => coverage.percent(missing_tests),
        :missing_coverage => missing_tests
      }
    end
    # GC.start # Needed? (Slows down)
    testsuites
  end

  private

  def discover_testcases(testsuite_path)
    testcases = {}
    testcase_source_files = discover_testcase_source_files(testsuite_path)
    # TODO: Clean up this file. The Sandbox was added as a quick and dirty
    #       performance improvement.
    Sandbox.reset
    # for testcase_file in testcase_source_files
    #   begin
    #     testcase = load_testcase(testcase_file)
    #   rescue TestCaseLoadError => error
    #     @errors << error
    #     next
    #   end
    #   next if testcase.nil?
    #   next if testcase.test_methods.empty?
    #   testcases[testcase] = testcase.test_methods
    # end
    testcase_source_files.each { |testcase_file|
      Sandbox.load(testcase_file)
    }
    Sandbox.test_classes.each { |testcase|
      # testcase = Sandbox.sym_to_class(test_class)
      testcases[testcase] = testcase.test_methods
    }
    testcases
  end

  # @param [String] testcase_filename
  # @return [String]
  def get_testcase_suitename(testcase_filename)
    path = File.expand_path(testcase_filename)
    parts = path.split(File::SEPARATOR)
    testcase_file = File.basename(testcase_filename)
    testcase_name = File.basename(testcase_filename, '.*')
    # The TC_*.rb file might be wrapped in a TC_* folder. The suite name is the
    # parent of either one of these.
    index = parts.index(testcase_name) || parts.index(testcase_file)
    parts[index - 1]
  end

  # @param [Array<String>] testsuite_paths
  # @return [Array<String>] Path to all test case files found.
  def discover_testcase_source_files(testsuite_path)
    testcase_filter = File.join(testsuite_path, 'TC_*.rb')
    Dir.glob(testcase_filter)
  end

  module Sandbox
    def self.load(testcase_filename)
      # Attempt to load the testcase so it can be inspected for testcases and
      # test methods. Any errors is wrapped up in a custom error type so it can
      # be caught further up and displayed in the UI.
      begin
        module_eval(File.read(testcase_filename), testcase_filename)
        Kernel.load testcase_filename # TODO: Needed? Can we 'move' the already evaluated test?
      rescue ScriptError, StandardError => error
        testcase_name = File.basename(testcase_filename, '.*')
        warn "#{error.class} Loading #{testcase_name}"
        warn self.format_load_backtrace(error)
        raise TestCaseLoadError.new(error)
      end
    end
    def self.sym_to_class(symbol)
      self.const_get(symbol)
    end
    def self.classes
      self.constants.select { |c| self.const_get(c).is_a?(Class) }
    end
    def self.test_classes
      # self.classes.map { |c| self.const_get(c) }.grep(TestUp::TestCase)
      klasses = []
      self.classes.each { |c|
        # klass = self.const_get(c)
        klass = Object.const_get(c)
        # klasses << klass if klass.singleton_class.ancestors.include?(TestUp::TestCase)
        klasses << klass if klass.ancestors.include?(TestUp::TestCase)
      }
      klasses
    end
    def self.reset
      self.classes.each { |klass|
        self.send(:remove_const, klass)
        Object.send(:remove_const, klass) if Object.constants.include?(klass)
      }
    end
    # @param [Exception] error
    # @return [String]
    def self.format_load_backtrace(error)
      file_basename = File.basename(__FILE__)
      index = error.backtrace.index { |line|
        line =~ /testup\/#{file_basename}:\d+:in `load'/i
      }
      filtered_backtrace = error.backtrace[0..index]
      error.message << "\n" << filtered_backtrace.join("\n")
    end
  end

  # @param [String] testcase_file
  # @return [Object|Nil] The TestUp::TestCase object.
  def load_testcase(testcase_file)
    testcase_name = File.basename(testcase_file, '.*')
    # If the test has been loaded before try to undefine it so that test methods
    # that has been renamed or removed doesn't linger. This will only work if
    # the testcase file is named idential to the testcase class.
    remove_old_tests(testcase_name.intern)
    # Cache the current list of testcase classes. This will only work properly
    # for tests prefixed with TC_*
    existing_test_classes = all_test_classes
    # Attempt to load the testcase so it can be inspected for testcases and
    # test methods. Any errors is wrapped up in a custom error type so it can
    # be caught further up and displayed in the UI.
    begin
      load testcase_file
    rescue ScriptError, StandardError => error
      warn "#{error.class} Loading #{testcase_name}"
      warn format_load_backtrace(error)
      raise TestCaseLoadError.new(error)
    end
    # Ideally there should be one test case per test file and the name of the
    # file and test class should be the same.
    # Because some of our older tests didn't conform to that we must inspect
    # what new classes was loaded.
    new_classes = all_test_classes - existing_test_classes
    new_test_classes = root_classes(new_classes)
    if new_test_classes.empty?
      # This happens if another test case loaded a test case with the same name.
      # Our old todo section has sections like that.
      warn "'#{testcase_name}' - No new test cases loaded."
      #warn existing_test_classes.sort{|a,b|a.name<=>b.name}.join("\n")
      return nil
    elsif new_test_classes.size > 1
      # NOTE: More than one test class is currently not supported.
      # TODO(thomthom): Sub-classes will trigger this. Fix this.
      warn "'#{testcase_name}' - " <<
        "More than one test class loaded: #{new_test_classes.join(', ')}"
      return nil
    end
    testcase = new_test_classes.first
    # If the testcase class didn't inherit from TestUp::TestCase we need to
    # ensure to extend it so the TestUp utility methods is availible.
    unless testcase.singleton_class.ancestors.include?(TestCaseExtendable)
      # TODO(thomthom): Hook this up to deprecation warning.
      #warn "Invalid testcase: #{testcase} (#{testcase.ancestors.inspect})"
      testcase.extend(TestCaseExtendable)
    end
    testcase
  end

  # @param [Array<Class>] klasses
  # @return [Array<Class>]
  def root_classes(klasses)
    klasses.select { |klass| !klass.name.include?('::') }
  end

  # @param [Exception] error
  # @return [String]
  def format_load_backtrace(error)
    file_basename = File.basename(__FILE__)
    index = error.backtrace.index { |line|
      line =~ /testup\/#{file_basename}:\d+:in `load'/i
    }
    filtered_backtrace = error.backtrace[0..index]
    error.message << "\n" << filtered_backtrace.join("\n")
  end

  # @return [Array<Class>]
  def all_test_classes
    klasses = []
    ObjectSpace.each_object(Class) { |klass|
      klasses << klass if klass.name =~ /^TC_/
    }
    klasses
  end

  # Remove the old testcase class so changes can be made without reloading
  # SketchUp. This is done because MiniTest is made to be run as a traditional
  # Ruby script on a web server where the lifespan of objects isn't persistent
  # as it is in SketchUp.
  #
  # @param [Symbol] testcase
  # @return [Nil]
  def remove_old_tests(testcase)
    if Object.constants.include?(testcase)
      Object.send(:remove_const, testcase)
      # Remove any previously loaded versions from MiniTest. Otherwise MiniTest
      # will keep running them along with the new ones.
      MiniTest::Runnable.runnables.delete_if { |klass|
        klass.to_s == testcase.to_s
      }
      GC.start
    end
    nil
  end

  end # class
end # module
