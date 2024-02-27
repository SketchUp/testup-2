#-------------------------------------------------------------------------------
#
# Copyright 2013-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

# Ruby 3.x removed SortedSet (https://github.com/ruby/set/pull/2).
# So, use the SortedSet implementation from Ruby 2.7.x.
if RUBY_VERSION >= '3.0'
  require 'testup/sorted_set'
else
  require 'set'
end

module TestUp
  module Report
    class Collection < SortedSet

      # @param [Integer, #hash] value
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
