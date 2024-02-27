#-------------------------------------------------------------------------------
#
# Copyright 2013-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'json'

require 'testup/from_hash'


module TestUp
  module Report
    class Test

      extend FromHash
      include Comparable

      attr_reader :title, :id, :result
      attr_writer :enabled

      # @param [Hash] hash
      # @return [Report::Test]
      def self.from_hash(hash)
        title, result, missing, enabled = typed_values(hash)
        new(title, result, missing: missing, enabled: enabled)
      end

      def initialize(title, result = nil, missing: false, enabled: true)
        @title = title.to_s
        @id = title.to_sym
        @result = result
        @missing = missing
        @enabled = enabled
      end

      def <=>(other)
        @id <=> other.id
      end

      def enabled?
        @enabled
      end

      def hash
        @id.hash
      end

      # @param [Report::Test] test
      # @return [Boolean]
      def merge_result(test)
        return false if test.result.nil?
        @result = test.result
        true
      end

      def missing?
        @missing
      end

      def to_h
        {
          title: @title,
          id: @id,
          result: @result,
          missing: @missing,
          enabled: @enabled,
        }
      end

      def to_json(*args)
        to_h.to_json(*args)
      end

      private

      def self.typed_structure
        {
          title: :to_s,
          result: Report::TestResult,
          missing: :bool,
          enabled: :bool,
        }
      end

    end # class
  end # module
end # module
