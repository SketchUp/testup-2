#-------------------------------------------------------------------------------
#
# Copyright 2014, Trimble Navigation Limited
#
# This software is provided as an example of using the Ruby interface
# to SketchUp.
#
# Permission to use, copy, modify, and distribute this software for
# any purpose and without fee is hereby granted, provided that the above
# copyright notice appear in all copies.
#
# THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
#
#-------------------------------------------------------------------------------


# Compatibility file to smoothen transition from our old tests to the new ones.


# Add the helper libs from the old TestUp which some tests used.
$LOAD_PATH << File.join(TestUp::PATH_OLD_TESTUP, 'lib')
$LOAD_PATH << File.join(TestUp::PATH_OLD_TESTUP, 'ruby')
if RUBY_VERSION.to_i == 1
  ruby_version = 'Ruby1.8'
else
  ruby_version = 'Ruby2.0'
end
$LOAD_PATH << File.join(TestUp::PATH_OLD_TESTUP, 'ruby', ruby_version)


# Prevent 'test/unit' from being loaded after minitest is loaded.
$LOADED_FEATURES << Sketchup.find_support_file('Tools/RubyStdLib/test/unit.rb')


# Remap Test::Unit to Minitest::Unit so the old tests will load.
module Test; Unit = Minitest::Unit; end


# Mute noisy warnings.
module Minitest
  class Unit
    class TestCase < Minitest::Test

      def self.inherited klass
        super
      end

    end # class TestCase
  end # class Unit
end # module Minitest


# Intercept calls to exit. It won't exit Ruby, but cause errors to be output to
# the console.
module Minitest

  def self.exit
    warn 'EXIT! Minitest tried to exit.'
  end

end # module Minitest


# Compatibility module for Minitest 5 which removed several assert_* methods
# compared to the old test/unit framework our tests originally used.
#
# We might want to consider phasing out the deprecated methods from our tests.
require 'minitest/assertions'

module Minitest
  module Assertions

    def _assertions
      assertions()
    end

    def _assertions=(*args)
      assertions = *args
    end


    alias :assert_raise :assert_raises


    # :call-seq:
    #   assert_nothing_raised( *args, &block )
    #
    #If any exceptions are given as arguments, the assertion will
    #fail if one of those exceptions are raised. Otherwise, the test fails
    #if any exceptions are raised.
    #
    #The final argument may be a failure message.
    #
    #    assert_nothing_raised RuntimeError do
    #      raise Exception #Assertion passes, Exception is not a RuntimeError
    #    end
    #
    #    assert_nothing_raised do
    #      raise Exception #Assertion fails
    #    end
    def assert_nothing_raised(*args)
      self._assertions += 1
      if Module === args.last
        msg = nil
      else
        msg = args.pop
      end
      begin
        line = __LINE__; yield
      rescue MiniTest::Skip
        raise
      rescue Exception => e
        bt = e.backtrace
        as = e.instance_of?(MiniTest::Assertion)
        if as
          ans = /\A#{Regexp.quote(__FILE__)}:#{line}:in /o
          bt.reject! {|ln| ans =~ ln}
        end
        if ((args.empty? && !as) ||
            args.any? {|a| a.instance_of?(Module) ? e.is_a?(a) : e.class == a })
          msg = message(msg) { "Exception raised:\n<#{mu_pp(e)}>" }
          raise MiniTest::Assertion, msg.call, bt
        else
          raise
        end
      end
      nil
    end

  end # module Assertions
end # module Test
