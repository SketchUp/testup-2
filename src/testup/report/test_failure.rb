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
    TestFailure = Struct.new(
        :type,     # String
        :message,  # String
        :location, # String
      ) do

      extend FromHash

      def self.typed_structure
        {
          type: String,
          message: String,
          location: String,
        }
      end

      def to_json(*args)
        to_h.to_json(*args)
      end

    end
  end # module
end # module
