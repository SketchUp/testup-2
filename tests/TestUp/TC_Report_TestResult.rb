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
      0,   # skipped
      1,   # passed
      0,   # error
      [],  # failures
    )
  end


  def test_to_h_default
    result = fixture_test_result_success
    expected = {
      run_time: 0.2,
      assertions: 3,
      skipped: 0,
      passed: 1,
      error: 0,
      failures: [],
    }
    assert_equal(expected, result.to_h)
  end


  def test_to_json_default
    result = fixture_test_result_success
    expected = {
      run_time: 0.2,
      assertions: 3,
      skipped: 0,
      passed: 1,
      error: 0,
      failures: [],
    }
    assert_equal(expected.to_json, result.to_json)
  end

end # class
