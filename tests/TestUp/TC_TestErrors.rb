# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


require 'testup/testcase'


# Set of tests triggering different result types.
class TC_TestErrors < TestUp::TestCase

  def setup
    # ...
  end

  def teardown
    # ...
  end


  # ========================================================================== #

  def test_pass
    assert(true)
  end # test

  def test_skip
    skip('Nah, not this time!')
  end # test

  def test_error
    raise ArgumentError, 'All your base are belong to us!'
  end # test


end # class
