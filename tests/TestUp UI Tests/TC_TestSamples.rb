# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


require 'testup/testcase'


# Set of tests triggering different result types.
class TC_TestSamples < TestUp::TestCase

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

  def test_failure
    assert(false, 'Oh no, how could this happen?!')
  end # test

  def test_equal_failure
    assert_equal(5, 2 + 2, 'This is all wrong')
  end # test

  def test_skip
    skip('Nah, not this time!')
  end # test

  def test_error
    raise 'Oh the humanity!'
  end # test


end # class
