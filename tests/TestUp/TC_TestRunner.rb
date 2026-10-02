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

    def runner
      TestUp::TestRunner.new(title: 'TestUp UI Tests', path: TESTUP_UI_TESTS_PATH)
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

  end # class
end # module
end # module
