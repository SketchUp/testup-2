# Copyright:: Copyright 2018 Trimble Inc
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen

require 'testup/testcase'
require 'testup/report/test'
require 'testup/report/test_result'


class TC_Report_Test < TestUp::TestCase

  def setup
    # ...
  end

  def teardown
    # ...
  end


  def fixture_test_result_success
    # TestUp::Report::TestResult.new(
    #   run_time: 0.2,
    #   assertions: 3,
    #   skipped: 0,
    #   passed: 1,
    #   error: 0,
    #   failures: [],
    # )
    TestUp::Report::TestResult.new(
      0.2, # run_time
      3,   # assertions
      0,   # skipped
      1,   # passed
      0,   # error
      [],  # failures
    )
  end


  def test_initialize_default
    test = TestUp::Report::Test.new('test_foo')
    assert_kind_of(String, test.title)
    assert_equal('test_foo', test.title)
    assert_kind_of(Symbol, test.id)
    assert_equal(:test_foo, test.id)
    assert(test.enabled?)
    refute(test.missing?)
    assert_nil(test.result)
  end

  def test_initialize_missing
    test = TestUp::Report::Test.new('test_foo', missing: true)
    assert_equal('test_foo', test.title)
    assert_equal(:test_foo, test.id)
    assert(test.enabled?)
    assert(test.missing?)
    assert_nil(test.result)
  end

  def test_initialize_with_result
    test = TestUp::Report::Test.new('test_foo', fixture_test_result_success)
    assert_equal('test_foo', test.title)
    assert_equal(:test_foo, test.id)
    assert(test.enabled?)
    refute(test.missing?)
    assert_kind_of(TestUp::Report::TestResult, test.result)
  end


  def test_comparable_array
    tests = [
      TestUp::Report::Test.new('foo'),
      TestUp::Report::Test.new('bar'),
      TestUp::Report::Test.new('biz'),
      TestUp::Report::Test.new('baz'),
    ]
    titles = tests.sort.map(&:title)
    expected = %w[bar baz biz foo]
    assert_equal(expected, titles)
  end


  def test_to_h_no_result
    test = TestUp::Report::Test.new('foo_bar')
    expected = {
      title: 'foo_bar',
      id: :foo_bar,
      result: nil,
      enabled: true,
      missing: false,
    }
    assert_equal(expected, test.to_h)
  end

  def test_to_json_with_result
    test = TestUp::Report::Test.new('foo_bar', fixture_test_result_success)
    expected = {
      title: 'foo_bar',
      id: :foo_bar,
      result: {
        run_time: 0.2,
        assertions: 3,
        skipped: 0,
        passed: 1,
        error: 0,
        failures: [],
      },
      enabled: true,
      missing: false,
    }
    assert_equal(expected.to_json, test.to_json)
  end

end # class
