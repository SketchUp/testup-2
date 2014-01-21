# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


require 'testup/testcase'


# Set of tests triggering different result types.
class TC_TestEnvironment < TestUp::TestCase

  def setup
    # ...
  end

  def teardown
    # ...
  end


  # ========================================================================== #

  def test_ruby_engine
    assert_equal(2, RUBY_VERSION.to_i)
  end # test

  def test_sketchup_environment
    assert_equal(14, Sketchup.version.to_i)
  end # test

  def test_skipped
    skip('This is not the test you are looking for...')
  end # test


end # class
