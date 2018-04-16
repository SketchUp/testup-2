# Copyright:: Copyright 2018 Trimble Inc
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen

require 'testup/testcase'
require 'testup/report/test_suite'


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
    assert(suite.test_case?('TC_Bar'))
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
              enabled: true,
              missing: false,
            },
            {
              title: 'baz',
              id: :baz,
              result: nil,
              enabled: true,
              missing: false,
            },
            {
              title: 'biz',
              id: :biz,
              result: nil,
              enabled: true,
              missing: false,
            },
            {
              title: 'biz_baz',
              id: :biz_baz,
              result: nil,
              enabled: true,
              missing: true,
            },
            {
              title: 'foo',
              id: :foo,
              result: nil,
              enabled: true,
              missing: false,
            },
            {
              title: 'foo_bar',
              id: :foo_bar,
              result: nil,
              enabled: true,
              missing: true,
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
              enabled: true,
              missing: true,
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
