# Copyright:: Copyright 2018 Trimble Inc
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen

require 'testup/testcase'
require 'testup/report/test_suite'
require 'testup/test_discoverer2'


class TC_TestDiscoverer < TestUp::TestCase

  def setup
    # ...
  end

  def teardown
    # ...
  end


  TESTS_PATH = File.expand_path('..', __dir__)
  TESTUP_UI_TESTS_PATH = File.join(TESTS_PATH, 'TestUp UI Tests')


  def test_discover_ui_tests
    paths = [TESTUP_UI_TESTS_PATH]
    discoverer = TestUp::TestDiscoverer2.new(paths)

    test_suites = discoverer.discover
    assert_equal(1, test_suites.size, 'Number of test suites')

    suite = test_suites.first
    assert_kind_of(TestUp::Report::TestSuite, suite)
    assert_equal('TestUp UI Tests', suite.title)

    expected = %w(TC_TestErrors TC_TestSamples)
    test_cases = suite.test_cases
    assert_equal(expected.size, test_cases.size, 'Number of test cases')
    titles = test_cases.map(&:title)
    assert_equal(expected, titles)

    tc_test_errors, tc_test_samples = test_cases.to_a
    assert_kind_of(TestUp::Report::TestCase, tc_test_errors, 'TC_TestErrors')
    assert_kind_of(TestUp::Report::TestCase, tc_test_samples, 'TC_TestSamples')

    expected = %w(test_error test_pass test_skip)
    assert_equal(expected.size, tc_test_errors.tests.size, 'Number of tests')
    titles = tc_test_errors.tests.map(&:title)
    assert_equal(expected, titles)

    expected = %w(test_equal_failure test_error test_failure test_pass test_skip)
    assert_equal(expected.size, tc_test_samples.tests.size, 'Number of tests')
    titles = tc_test_samples.tests.map(&:title)
    assert_equal(expected, titles)
  end

end # class
