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


  def test_initialize_default
    suite = TestUp::Report::TestSuite.new('Suite Title')
    assert_equal('Suite Title', suite.title)
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
    suite = TestUp::Report::TestSuite.new('Suite Title', test_cases)
    assert_equal('Suite Title', suite.title)
    assert_equal(:suite_title, suite.id)

    assert_kind_of(Enumerable, suite.test_cases)
    assert_equal(test_cases.size, suite.test_cases.size)
    assert_nil(suite.coverage)
  end

  # def test_initialize_with_test_cases_and_coverage
  #   test_cases = [
  #     TestUp::Report::TestCase.new('TC_Foo'),
  #     TestUp::Report::TestCase.new('TC_Bar'),
  #     TestUp::Report::TestCase.new('TC_Biz'),
  #     TestUp::Report::TestCase.new('TC_Baz'),
  #   ]
  #   suite = TestUp::Report::TestSuite.new('Suite Title', test_cases)
  #   assert_equal('Suite Title', suite.title)
  #   assert_equal(:suite_title, suite.id)

  #   assert_kind_of(Enumerable, suite.test_cases)
  #   assert_equal(test_cases.size, suite.test_cases.size)
  #   assert_nil(suite.coverage)
  # end


  def test_test_cases_sorted
    test_cases = [
      TestUp::Report::TestCase.new('TC_Foo'),
      TestUp::Report::TestCase.new('TC_Bar'),
      TestUp::Report::TestCase.new('TC_Biz'),
      TestUp::Report::TestCase.new('TC_Baz'),
    ]
    suite = TestUp::Report::TestSuite.new('Example Suite', test_cases)
    titles = suite.test_cases.map(&:title)
    expected = %w[TC_Bar TC_Baz TC_Biz TC_Foo]
    assert_equal(expected, titles)
  end


  def test_to_h_default
    suite = TestUp::Report::TestSuite.new('Example Suite')
    expected = {
      title: 'Example Suite',
      id: :example_suite,
      test_cases: [],
      coverage: nil,
    }
    assert_equal(expected, suite.to_h)
  end


  def test_to_json_with_tests
    test_cases = [
      TestUp::Report::TestCase.new('TC_Example')
    ]
    suite = TestUp::Report::TestSuite.new('Example Suite', test_cases)
    expected = {
      title: 'Example Suite',
      id: :example_suite,
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

end # class
