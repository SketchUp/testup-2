# Copyright:: Copyright 2018 Trimble Inc
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen

require 'testup/testcase'
require 'testup/report/test_result'


class TC_Report_TestResult < TestUp::TestCase

  def setup
    # ...
  end

  def teardown
    # ...
  end


  def fixture_test_result_success
    TestUp::Report::TestResult.new(
      0.2, # run_time
      3,   # assertions
      false,   # skipped
      true,   # passed
      false,   # error
      [],  # failures
    )
  end


  def test_from_hash_without_failures
    expected = {
      run_time: 0.2,
      assertions: 3,
      skipped: false,
      passed: true,
      error: false,
      failures: [],
    }
    result = TestUp::Report::TestResult.from_hash(expected)
    result.is_a?(TestUp::Report::TestResult)
    assert_equal(expected.to_json, result.to_json)
  end

  def test_from_hash_with_failures
    expected = {
      run_time: 0.2,
      assertions: 3,
      skipped: false,
      passed: true,
      error: false,
      failures: [
        {
          type: 'Error',
          message: 'ArgumentError: Hello World',
          location: 'tests/TestUp/TC_TestErrors.rb:32',
        }
      ],
    }
    result = TestUp::Report::TestResult.from_hash(expected)
    assert_kind_of(TestUp::Report::TestResult, result)
    assert_equal(1, result.failures.size)
    assert_kind_of(TestUp::Report::TestFailure, result.failures[0])
    assert_equal(expected.to_json, result.to_json)
  end


  def test_to_h_default
    result = fixture_test_result_success
    expected = {
      run_time: 0.2,
      assertions: 3,
      skipped: false,
      passed: true,
      error: false,
      failures: [],
    }
    assert_equal(expected, result.to_h)
  end


  def test_to_json_default
    result = fixture_test_result_success
    expected = {
      run_time: 0.2,
      assertions: 3,
      skipped: false,
      passed: true,
      error: false,
      failures: [],
    }
    assert_equal(expected.to_json, result.to_json)
  end

end # class
