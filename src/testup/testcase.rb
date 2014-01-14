# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


require File.join(__dir__, 'minitest_setup.rb')


module TestUp

  class TestCase < MiniTest::Unit::TestCase

    def self.test_methods
      tests = public_instance_methods(true).grep(/^test_/i).sort
    end

  end # class

end # module
