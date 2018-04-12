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
          enabled: true,
          missing: false,
        },
      ],
    }
    assert_equal(expected.to_json, test_case.to_json)
  end

end # class
