# Copyright:: Copyright 2018 Trimble Inc
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen

require 'testup/testcase'
require 'testup/report/test_failure'


class TC_Report_TestFailure < TestUp::TestCase

  def setup
    # ...
  end

  def teardown
    # ...
  end


  def test_to_json
    type = 'Error'
    message = 'ArgumentError: Hello World'
    location = 'tests/TestUp/TC_TestErrors.rb:32'
    failure = TestUp::Report::TestFailure.new(type, message, location)
    expected = {
      type: type,
      message: message,
      location: location,
    }
    assert_equal(expected.to_json, failure.to_json)
  end

end # class
