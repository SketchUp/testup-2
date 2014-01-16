# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


require File.join(__dir__, 'minitest_setup.rb')
require File.join(__dir__, 'sketchup_test_utilities.rb')


module TestUp

  module TestCaseExtendable

    def test_methods
      tests = public_instance_methods(true).grep(/^test_/i).sort
    end

  end # module TestCaseExtendable


  class TestCase < Minitest::Test

    include SketchUpTestUtilities
    extend TestCaseExtendable

  end # class

end # module
