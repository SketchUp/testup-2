# Copyright:: Copyright 2026 Trimble Inc
# License:: The MIT License (MIT)

require 'testup/testcase'
require 'testup/api'
require 'testup/test_runner'


module TestUp
module Tests
  class TC_TestRunner < TestUp::TestCase

    TESTS_PATH = File.expand_path('..', __dir__)
    TESTUP_UI_TESTS_PATH = File.join(TESTS_PATH, 'TestUp UI Tests')

    # The checks run before any test does, so they can be tested without
    # starting a nested Minitest run.
    def runner
      TestUp::TestRunner.new(title: 'TestUp UI Tests', path: TESTUP_UI_TESTS_PATH)
    end

    def ui_test_suite
      TestUp::API.discover_tests([TESTUP_UI_TESTS_PATH]).first
    end

    def check_tests_exist(tests)
      runner = self.runner
      patterns = runner.send(:parse, tests)
      runner.send(:check_tests_exist, tests, patterns, ui_test_suite)
    end


    def test_parse_whole_test_case
      patterns = runner.send(:parse, ['TC_Foo#', 'TC_Foo#test_bar'])
      assert_equal(['TC_Foo#.+', 'TC_Foo#test_bar'], patterns)
    end


    def test_parse_leaves_arguments_unchanged
      tests = ['TC_Foo#']
      runner.send(:parse, tests)
      assert_equal(['TC_Foo#'], tests)
    end


    def test_parse_frozen_strings
      patterns = runner.send(:parse, ['TC_Foo#'.freeze])
      assert_equal(['TC_Foo#.+'], patterns)
    end


    def test_check_tests_exist
      check_tests_exist([
        'TestUp::Tests::TC_TestSamples#',
        'TestUp::Tests::TC_TestPasses#test_pass_only_test_case',
        'TestUp::Tests::TC_TestSamples#test_(pass|skip)',
      ])
    end


    def test_check_tests_exist_unknown_test_case
      error = assert_raises(ArgumentError) {
        check_tests_exist(['TestUp::Tests::TC_TestSamples#', 'TC_TestSamples#'])
      }
      assert_match(/No tests match: TC_TestSamples#\./, error.message)
      assert_includes(error.message, 'TestUp::Tests::TC_TestSamples')
    end


    def test_check_tests_exist_unknown_test
      error = assert_raises(ArgumentError) {
        check_tests_exist(['TestUp::Tests::TC_TestSamples#test_nope'])
      }
      assert_match(/No tests match: TestUp::Tests::TC_TestSamples#test_nope\./, error.message)
    end

  end # class
end # module
end # module
