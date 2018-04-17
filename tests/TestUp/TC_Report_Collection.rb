# Copyright:: Copyright 2018 Trimble Inc
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen

require 'testup/testcase'
require 'testup/report/collection'
require 'testup/report/test'


class TC_Report_Collection < TestUp::TestCase

  def setup
    # ...
  end

  def teardown
    # ...
  end


  def test_Operator_Get_by_numeric_index
    tests = [
      TestUp::Report::Test.new('test_foo'),
      TestUp::Report::Test.new('test_bar'),
      TestUp::Report::Test.new('test_biz'),
    ]
    collection = TestUp::Report::Collection.new(tests)
    assert_equal(tests[1], collection[1], 'Index access')
    assert_equal(tests[1], collection[:test_bar], 'Hash access')
    test = TestUp::Report::Test.new('test_bar')
    assert_equal(tests[1], collection[test], 'Hash access')
  end

end # class
