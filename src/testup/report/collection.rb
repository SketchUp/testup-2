#-------------------------------------------------------------------------------
#
# Copyright 2013-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'set'


module TestUp
  module Report
    class Collection < SortedSet

      # @param [Integer, #hash]
      def [](value)
        # return @hash.keys[value] if value.is_a?(Integer)
        return each.to_a[value] if value.is_a?(Integer)
        value = value.to_sym if value.is_a?(String)
        @hash.each { |key, _| return key if key.hash == value.hash }
        nil
      end

    end # class
  end # module
end # module
