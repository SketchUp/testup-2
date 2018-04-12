#-------------------------------------------------------------------------------
#
# Copyright 2013-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'json'
require 'set'

require 'testup/type_check'


module TestUp
  module Report
    class TestCase

      include Comparable
      include TypeCheck

      attr_reader :title, :id, :tests

      # @param [String] title
      # @param [Array<Report::Test>] tests
      def initialize(title, tests = [])
        expect_all_type(Report::Test, tests)
        @title = title.to_s
        @id = title.to_sym
        @tests = SortedSet.new(tests)
        @enabled = true
        @expanded = false
      end

      def <=>(other)
        @id <=> other.id
      end

      def enabled?
        @enabled
      end

      def expanded?
        @expanded
      end

      def to_h
        {
          title: @title,
          id: @id,
          enabled: true,
          expanded: false,
          tests: @tests.to_a,
        }
      end

      def to_json(*args)
        to_h.to_json(*args)
      end

    end # class
  end # module
end # module
