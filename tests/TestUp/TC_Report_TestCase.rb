# Copyright:: Copyright 2018 Trimble Inc
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen

require 'testup/testcase'
require 'testup/report/test_case'


class TC_Report_TestCase < TestUp::TestCase

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

  def fixture_test_result_failure
    TestUp::Report::TestResult.new(
      0.2, # run_time
      3,   # assertions
      0,   # skipped
      0,   # passed
      1,   # error
      [],  # failures
    )
  end


  def test_initialize_default
    test_case = TestUp::Report::TestCase.new('TC_Example')
    assert_kind_of(String, test_case.title)
    assert_equal('TC_Example', test_case.title)
    assert_kind_of(Symbol, test_case.id)
    assert_equal(:TC_Example, test_case.id)
    assert(test_case.enabled?)
    refute(test_case.expanded?)

    assert_kind_of(Enumerable, test_case.tests)
    assert_empty(test_case.tests)
  end


  def test_from_hash_without_tests
    expected = {
      title: 'TC_Example',
      id: :TC_Example,
      enabled: false,
      expanded: true,
      tests: [],
    }
    test_case = TestUp::Report::TestCase.from_hash(expected)
    assert_kind_of(TestUp::Report::TestCase, test_case)
    assert_equal(expected.to_json, test_case.to_json)
  end

  def test_from_hash_with_tests
    expected = {
      title: 'TC_Example',
      id: :TC_Example,
      enabled: true,
      expanded: false,
      tests: [
        {
          title: 'foo_bar',
          id: :foo_bar,
          result: nil,
          missing: false,
          enabled: true,
        },
      ],
    }
    test_case = TestUp::Report::TestCase.from_hash(expected)
    assert_kind_of(TestUp::Report::TestCase, test_case)
    assert_kind_of(TestUp::Report::Test, test_case.tests[0])
    assert_equal(expected.to_json, test_case.to_json)
  end


  def test_hash
    test = TestUp::Report::Test.new('test_foo')
    assert_equal(:test_foo.hash, test.hash)
  end


  def test_merge_results
    tests_old = [
      TestUp::Report::Test.new('test_bar'),
      TestUp::Report::Test.new('test_biz'),
      TestUp::Report::Test.new('test_foo'),
    ]
    test_case_old = TestUp::Report::TestCase.new('TC_Example', tests_old)

    tests_new = [
      TestUp::Report::Test.new('test_bar', fixture_test_result_failure),
      TestUp::Report::Test.new('test_biz', fixture_test_result_success),
      TestUp::Report::Test.new('test_foo'),
    ]
    test_case_new = TestUp::Report::TestCase.new('TC_Example', tests_new)

    assert_nil(test_case_old.merge_results(test_case_new))
    assert_kind_of(TestUp::Report::TestResult, test_case_old.tests[0].result)
    assert_kind_of(TestUp::Report::TestResult, test_case_old.tests[1].result)
    assert_nil(test_case_old.tests[2].result)
    assert_equal(fixture_test_result_failure, test_case_old.tests[0].result)
    assert_equal(fixture_test_result_success, test_case_old.tests[1].result)
  end


  def test_rediscover
    tests_old = [
      TestUp::Report::Test.new('test_bar'),
      TestUp::Report::Test.new('test_baz', fixture_test_result_success),
      TestUp::Report::Test.new('test_foo', fixture_test_result_failure),
    ]
    tests_old[2].enabled = false
    test_case_old = TestUp::Report::TestCase.new('TC_Example', tests_old)

    tests_new = [
      TestUp::Report::Test.new('test_bar'),
      TestUp::Report::Test.new('test_biz'),
      TestUp::Report::Test.new('test_foo'),
    ]
    tests_new[0].enabled = false
    test_case_new = TestUp::Report::TestCase.new('TC_Example', tests_new)

    assert_nil(test_case_old.rediscover(test_case_new))

    expected_titles = test_case_new.tests.map(&:title)
    test_titles = test_case_old.tests.map(&:title)
    assert_equal(expected_titles, test_titles)

    assert_nil(test_case_old.tests[0].result)
    assert_nil(test_case_old.tests[1].result)
    assert_kind_of(TestUp::Report::TestResult, test_case_old.tests[2].result)
    assert_equal(fixture_test_result_failure, test_case_old.tests[2].result)
  end


  def test_test_covered_Query_string_argument
    tests = [
      TestUp::Report::Test.new('test_foo'),
      TestUp::Report::Test.new('test_bar_happy_path'),
      TestUp::Report::Test.new('test_bar_arguments'),
    ]
    test_case = TestUp::Report::TestCase.new('TC_Example', tests)
    assert(test_case.test_covered?('test_foo'), 'test_foo')
    assert(test_case.test_covered?('test_bar'), 'test_bar')
  end

  def test_test_covered_Query_class_argument
    tests = [
      TestUp::Report::Test.new('test_foo'),
      TestUp::Report::Test.new('test_bar_happy_path'),
      TestUp::Report::Test.new('test_bar_arguments'),
    ]
    test_foo = TestUp::Report::Test.new('test_foo')
    test_bar = TestUp::Report::Test.new('test_bar')
    test_case = TestUp::Report::TestCase.new('TC_Example', tests)
    assert(test_case.test_covered?(test_foo), 'test_foo')
    assert(test_case.test_covered?(test_bar), 'test_bar')
  end


  def test_tests_sorted
    tests = [
      TestUp::Report::Test.new('foo'),
      TestUp::Report::Test.new('bar'),
      TestUp::Report::Test.new('biz'),
      TestUp::Report::Test.new('baz'),
    ]
    test_case = TestUp::Report::TestCase.new('TC_Example', tests)
    titles = test_case.tests.map(&:title)
    expected = %w[bar baz biz foo]
    assert_equal(expected, titles)
  end


  def test_to_h_default
    test_case = TestUp::Report::TestCase.new('TC_Example')
    expected = {
      title: 'TC_Example',
      id: :TC_Example,
      enabled: true,
      expanded: false,
      tests: [],
    }
    assert_equal(expected, test_case.to_h)
  end


  def test_to_json_with_tests
    tests = [
      TestUp::Report::Test.new('foo_bar'),
    ]
    test_case = TestUp::Report::TestCase.new('TC_Example', tests)
    expected = {
      title: 'TC_Example',
      id: :TC_Example,
      enabled: true,
      expanded: false,
      tests: [
        {
          title: 'foo_bar',
          id: :foo_bar,
          result: nil,
          missing: false,
          enabled: true,
        },
      ],
    }
    assert_equal(expected.to_json, test_case.to_json)
  end

end # class
