# Copyright:: Copyright 2018 Trimble Inc
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen

require 'testup/testcase'
require 'testup/report/test_case'
require 'testup/report/test_coverage'
require 'testup/report/test_result'
require 'testup/report/test_suite'
require 'testup/report/test'


class TC_Report_TestSuite < TestUp::TestCase

  def setup
    # ...
  end

  def teardown
    # ...
  end


  FAKE_PATH = 'testup/fake/path'

  def fixture_coverage_missing_tests
    missing = {
      'TC_Example': [
        'foo_bar',
        'biz_baz',
      ],
      'TC_Hello': [
        'world',
      ],
    }
    TestUp::Report::TestCoverage.new(85.6, missing)
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

  def fixture_test_result_failure
    TestUp::Report::TestResult.new(
      0.2, # run_time
      3,   # assertions
      false,   # skipped
      false,   # passed
      true,   # error
      [],  # failures
    )
  end


  def test_initialize_default
    suite = TestUp::Report::TestSuite.new('Suite Title', FAKE_PATH)
    assert_kind_of(String, suite.title)
    assert_equal('Suite Title', suite.title)
    assert_kind_of(Symbol, suite.id)
    assert_equal(:suite_title, suite.id)

    assert_kind_of(Enumerable, suite.test_cases)
    assert_empty(suite.test_cases)

    assert_nil(suite.coverage)
  end

  def test_initialize_with_test_cases
    test_cases = [
      TestUp::Report::TestCase.new('TC_Foo'),
      TestUp::Report::TestCase.new('TC_Bar'),
      TestUp::Report::TestCase.new('TC_Biz'),
      TestUp::Report::TestCase.new('TC_Baz'),
    ]
    suite = TestUp::Report::TestSuite.new('Suite Title', FAKE_PATH, test_cases)
    assert_equal('Suite Title', suite.title)
    assert_equal(:suite_title, suite.id)

    assert_kind_of(Enumerable, suite.test_cases)
    assert_equal(test_cases.size, suite.test_cases.size)
    assert_nil(suite.coverage)
  end


  def test_from_hash_without_tests
    expected = {
      title: 'Example Suite',
      id: :example_suite,
      path: FAKE_PATH,
      test_cases: [],
      coverage: nil,
    }
    suite = TestUp::Report::TestSuite.from_hash(expected)
    assert_kind_of(TestUp::Report::TestSuite, suite)
    assert_equal(expected.to_json, suite.to_json)
  end

  def test_from_hash_with_tests
    expected = {
      title: 'Example Suite',
      id: :example_suite,
      path: FAKE_PATH,
      test_cases: [
        {
          title: 'TC_Example',
          id: :TC_Example,
          enabled: true,
          expanded: false,
          tests: [],
        }
      ],
      coverage: nil,
    }
    suite = TestUp::Report::TestSuite.from_hash(expected)
    assert_kind_of(TestUp::Report::TestSuite, suite)
    assert_kind_of(TestUp::Report::TestCase, suite.test_cases[0])
    assert_equal(expected.to_json, suite.to_json)
  end

  def test_from_hash_with_coverage
    expected = {
      title: 'Example Suite',
      id: :example_suite,
      path: FAKE_PATH,
      test_cases: [],
      coverage: {
        percent: 0.0,
        missing: [],
      },
    }
    suite = TestUp::Report::TestSuite.from_hash(expected)
    assert_kind_of(TestUp::Report::TestSuite, suite)
    assert_kind_of(TestUp::Report::TestCoverage, suite.coverage)
    assert_equal(expected[:coverage][:percent], suite.coverage.percent)
  end


  def test_merge_results
    tests_old = [
      TestUp::Report::Test.new('test_bar'),
      TestUp::Report::Test.new('test_biz'),
      TestUp::Report::Test.new('test_foo'),
    ]
    test_cases_old = [
      TestUp::Report::TestCase.new('TC_Example', tests_old),
      TestUp::Report::TestCase.new('TC_Hello'),
    ]
    suite_old = TestUp::Report::TestSuite.new('Example', FAKE_PATH,
                                              test_cases_old)

    tests_new = [
      TestUp::Report::Test.new('test_bar', fixture_test_result_failure),
      TestUp::Report::Test.new('test_biz', fixture_test_result_success),
      TestUp::Report::Test.new('test_foo'),
    ]
    test_cases_new = [
      TestUp::Report::TestCase.new('TC_Example', tests_new),
    ]
    suite_new = TestUp::Report::TestSuite.new('Example', FAKE_PATH,
                                              test_cases_new)

    assert_equal(suite_old, suite_old.merge_results(suite_new))
    test_case_old = test_cases_old[0]
    test_case_new = test_cases_new[0]
    assert_kind_of(TestUp::Report::TestResult, test_case_old.tests[0].result)
    assert_kind_of(TestUp::Report::TestResult, test_case_old.tests[1].result)
    assert_nil(test_case_old.tests[2].result)
    assert_equal(fixture_test_result_failure, test_case_old.tests[0].result)
    assert_equal(fixture_test_result_success, test_case_old.tests[1].result)
  end


  def test_rediscover
    tests_old = [
      TestUp::Report::Test.new('test_bar'),
      TestUp::Report::Test.new('test_biz'),
      TestUp::Report::Test.new('test_foo'),
    ]
    test_cases_old = [
      TestUp::Report::TestCase.new('TC_Example', tests_old),
      TestUp::Report::TestCase.new('TC_Hello'),
    ]
    test_cases_old[0].expanded = false
    test_cases_old[0].enabled = false
    suite_old = TestUp::Report::TestSuite.new('Example', FAKE_PATH,
                                              test_cases_old)

    tests_new = [
      TestUp::Report::Test.new('test_bar'),
      TestUp::Report::Test.new('test_baz'),
      TestUp::Report::Test.new('test_foo'),
    ]
    test_cases_new = [
      TestUp::Report::TestCase.new('TC_Example', tests_new),
      TestUp::Report::TestCase.new('TC_World'),
    ]
    suite_new = TestUp::Report::TestSuite.new('Example', FAKE_PATH,
                                              test_cases_new)

    tc_example = suite_old.test_case('TC_Example')
    refute(tc_example.enabled?, 'Enabled')
    refute(tc_example.expanded?, 'Expanded')

    assert_equal(suite_old, suite_old.rediscover(suite_new))

    test_case_titles = suite_old.test_cases.map(&:title)
    expected_test_case_titles = suite_new.test_cases.map(&:title)
    assert_equal(expected_test_case_titles, test_case_titles)

    refute(tc_example.enabled?, 'Enabled')
    refute(tc_example.expanded?, 'Expanded')
    test_titles = tc_example.tests.map(&:title)
    expected_test_titles = tests_new.map(&:title)
    assert_equal(expected_test_titles, test_titles)

    assert_empty(suite_old.test_case('TC_World').tests)
  end


  def test_test_case
    test_cases = [
      TestUp::Report::TestCase.new('TC_Foo'),
      TestUp::Report::TestCase.new('TC_Bar'),
      TestUp::Report::TestCase.new('TC_Biz'),
      TestUp::Report::TestCase.new('TC_Baz'),
    ]
    suite = TestUp::Report::TestSuite.new('Example Suite', FAKE_PATH, test_cases)

    test_case = suite.test_case('TC_Bar')
    assert_kind_of(TestUp::Report::TestCase, test_case)
    assert_equal('TC_Bar', test_case.title)

    test_case = suite.test_case('TC_Bar')
    assert_kind_of(TestUp::Report::TestCase, test_case, 'array access')
    assert_equal('TC_Bar', test_case.title)
  end


  def test_test_case_Query
    test_cases = [
      TestUp::Report::TestCase.new('TC_Foo'),
      TestUp::Report::TestCase.new('TC_Bar'),
      TestUp::Report::TestCase.new('TC_Biz'),
      TestUp::Report::TestCase.new('TC_Baz'),
    ]
    suite = TestUp::Report::TestSuite.new('Example Suite', FAKE_PATH, test_cases)
    assert(suite.test_case?('TC_Bar'), 'TestCase not found')
  end


  def test_test_cases_sorted
    test_cases = [
      TestUp::Report::TestCase.new('TC_Foo'),
      TestUp::Report::TestCase.new('TC_Bar'),
      TestUp::Report::TestCase.new('TC_Biz'),
      TestUp::Report::TestCase.new('TC_Baz'),
    ]
    suite = TestUp::Report::TestSuite.new('Example Suite', FAKE_PATH, test_cases)
    titles = suite.test_cases.map(&:title)
    expected = %w[TC_Bar TC_Baz TC_Biz TC_Foo]
    assert_equal(expected, titles)
  end


  def test_to_h_default
    suite = TestUp::Report::TestSuite.new('Example Suite', FAKE_PATH)
    expected = {
      title: 'Example Suite',
      id: :example_suite,
      path: FAKE_PATH,
      test_cases: [],
      coverage: nil,
    }
    assert_equal(expected, suite.to_h)
  end


  def test_to_json_with_tests
    test_cases = [
      TestUp::Report::TestCase.new('TC_Example')
    ]
    suite = TestUp::Report::TestSuite.new('Example Suite', FAKE_PATH, test_cases)
    expected = {
      title: 'Example Suite',
      id: :example_suite,
      path: FAKE_PATH,
      test_cases: [
        {
          title: 'TC_Example',
          id: :TC_Example,
          enabled: true,
          expanded: false,
          tests: [],
        }
      ],
      coverage: nil,
    }
    assert_equal(expected.to_json, suite.to_json)
  end


  def test_to_json_with_coverage
    tests = [
      TestUp::Report::Test.new('foo'),
      TestUp::Report::Test.new('bar'),
      TestUp::Report::Test.new('biz'),
      TestUp::Report::Test.new('baz'),
    ]
    test_cases = [
      TestUp::Report::TestCase.new('TC_Example', tests)
    ]
    suite = TestUp::Report::TestSuite.new('Example Suite', FAKE_PATH, test_cases,
      coverage: fixture_coverage_missing_tests)
    expected = {
      title: 'Example Suite',
      id: :example_suite,
      path: FAKE_PATH,
      test_cases: [
        {
          title: 'TC_Example',
          id: :TC_Example,
          enabled: true,
          expanded: false,
          tests: [
            {
              title: 'bar',
              id: :bar,
              result: nil,
              missing: false,
              enabled: true,
            },
            {
              title: 'baz',
              id: :baz,
              result: nil,
              missing: false,
              enabled: true,
            },
            {
              title: 'biz',
              id: :biz,
              result: nil,
              missing: false,
              enabled: true,
            },
            {
              title: 'biz_baz',
              id: :biz_baz,
              result: nil,
              missing: true,
              enabled: true,
            },
            {
              title: 'foo',
              id: :foo,
              result: nil,
              missing: false,
              enabled: true,
            },
            {
              title: 'foo_bar',
              id: :foo_bar,
              result: nil,
              missing: true,
              enabled: true,
            },
          ],
        },
        {
          title: 'TC_Hello',
          id: :TC_Hello,
          enabled: true,
          expanded: false,
          tests: [
            {
              title: 'world',
              id: :world,
              result: nil,
              missing: true,
              enabled: true,
            },
          ],
        },
      ],
      coverage: {
        percent: 85.6,
      },
    }
    assert_equal(expected.to_json, suite.to_json)
  end

end # class
