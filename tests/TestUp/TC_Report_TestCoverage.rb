# Copyright:: Copyright 2018 Trimble Inc
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen

require 'testup/testcase'
require 'testup/report/test_coverage'


module TestUp
module Tests
  class TC_Report_TestCoverage < TestUp::TestCase

    def setup
      # ...
    end

    def teardown
      # ...
    end


    def test_initialize_default
      coverage = TestUp::Report::TestCoverage.new(100.0, {})
      assert_equal(100.0, coverage.percent)
      assert_empty(coverage.missing)
    end


    def test_from_hash
      expected = {
        percent: 85.6,
        missing: [
          {
            title: 'TC_Example',
            id: :TC_Example,
            enabled: true,
            expanded: false,
            tests: [],
          },
        ],
      }
      coverage = TestUp::Report::TestCoverage.from_hash(expected)
      assert_kind_of(Float, coverage.percent)
      assert_equal(expected[:percent], coverage.percent)
      assert_kind_of(TestUp::Report::TestCase, coverage.missing[0])
      assert_equal(expected[:missing][0], coverage.missing[0].to_h)
    end


    def test_to_h_default
      coverage = TestUp::Report::TestCoverage.new(100.0, {})
      expected = {
        percent: 100.0,
      }
      assert_equal(expected, coverage.to_h)
    end


    def test_to_json_with_missing_tests
      missing = {
        'TC_Example' => [
          'foo_bar',
        ],
      }
      coverage = TestUp::Report::TestCoverage.new(85.6, missing)
      expected = {
        percent: 85.6,
      }
      assert_equal(expected.to_json, coverage.to_json)
    end

  end # class
end
end
