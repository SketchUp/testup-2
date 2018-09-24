# Copyright:: Copyright 2018 Trimble Inc
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen

require 'testup/testcase'
require 'testup/report/test'
require 'testup/report/test_case'
require 'testup/report/test_coverage'
require 'testup/report/test_result'
require 'testup/report/test_suite'
require 'testup/coverage_discoverer'


class TC_CoverageDiscoverer < TestUp::TestCase

  def setup
    # ...
  end

  def teardown
    # ...
  end


  TESTS_PATH = File.expand_path('..', __dir__)
  TESTUP_UI_TESTS_PATH = File.join(TESTS_PATH, 'TestUp UI Tests')


  def fake_manifest
    manifest = Minitest::Mock.new
    manifest.expect :exist?, true
    manifest.expect :expected_methods, [
      'TestSamples.pass',
      'TestSamples.failure',
      'TestSamples.equal_failure',
      'TestSamples.skip',
      'TestSamples.error',
    ]
    manifest
  end

  def fixture_discovered_test_suite
    tc_test_errors_tests = [
      TestUp::Report::Test.new('test_pass'),
      TestUp::Report::Test.new('test_skip'),
      TestUp::Report::Test.new('test_error'),
    ]
    tc_test_samples = [
      TestUp::Report::Test.new('test_pass'),
      TestUp::Report::Test.new('test_failure'),
      TestUp::Report::Test.new('test_equal_failure'),
    ]
    test_cases = [
      TestUp::Report::TestCase.new('TC_TestErrors', tc_test_errors_tests),
      TestUp::Report::TestCase.new('TC_TestSamples', tc_test_samples),
    ]
    path = TESTUP_UI_TESTS_PATH
    suite = TestUp::Report::TestSuite.new('TestSuite', path, test_cases)
  end


  def test_report_with_manifest
    discoverer = TestUp::CoverageDiscoverer.new
    coverage = TestUp::Manifest.stub :new, fake_manifest do
      discoverer.report(fixture_discovered_test_suite)
    end
    assert_kind_of(TestUp::Report::TestCoverage, coverage)

    assert_equal(1, coverage.missing.size, 'missing test cases')

    titles = coverage.missing.map(&:title)
    expected = %w(TC_TestSamples)
    assert_equal(2, coverage.missing[0].tests.size, 'missing tests')

    titles = coverage.missing[0].tests.map(&:title)
    expected = %w(test_error test_skip)
    assert_equal(expected, titles)

    missing = coverage.missing[0].tests.map(&:missing?)
    expected = [true, true]
    assert_equal(expected, missing)

    assert_equal(40.0, coverage.percent)
  end

  def test_report_with_no_manifest
    discoverer = TestUp::CoverageDiscoverer.new
    coverage = discoverer.report(fixture_discovered_test_suite)
    assert_kind_of(TestUp::Report::TestCoverage, coverage)
    assert_empty(coverage.missing, 'Test cases')
    assert_equal(0.0, coverage.percent)
  end

end # class
