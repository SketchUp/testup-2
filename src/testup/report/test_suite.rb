#-------------------------------------------------------------------------------
#
# Copyright 2013-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'json'
require 'set'


module TestUp
  module Report
    class TestSuite

      attr_reader :title, :id, :test_cases, :coverage

      def initialize(title, test_cases = [])
        @title = title
        @id = to_id(title)
        @test_cases = SortedSet.new(test_cases)
        @coverage = nil
      end

      def to_h
        {
          title: @title,
          id: @id,
          test_cases: @test_cases.to_a,
          coverage: @coverage,
        }
      end

      def to_json(*args)
        to_h.to_json(*args)
      end

      private

      def to_id(string)
        string.downcase.tr(' ', '_').to_sym
      end

    end # class
  end # module
end # module
