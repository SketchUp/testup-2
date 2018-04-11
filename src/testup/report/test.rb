#-------------------------------------------------------------------------------
#
# Copyright 2013-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'json'


module TestUp
  module Report
    class Test

      include Comparable

      attr_reader :title, :id, :result

      def initialize(title, result = nil, missing: false)
        @title = title
        @id = title.to_sym
        @result = result
        @enabled = true
        @missing = missing
      end

      def <=>(other)
        @id <=> other.id
      end

      def enabled?
        @enabled
      end

      def missing?
        @missing
      end

      def to_h
        {
          title: @title,
          id: @id,
          result: @result,
          enabled: @enabled,
          missing: @missing,
        }
      end

      def to_json(*args)
        to_h.to_json(*args)
      end

    end # class
  end # module
end # module
