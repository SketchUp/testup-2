#-------------------------------------------------------------------------------
#
# Copyright 2013-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------


module TestUp
  module TypeCheck

    # @param [Class] type
    # @param [Enumerable] enumerable
    def expect_all_type(type, enumerable)
      enumerable.each { |object| expect_type(type, object) }
    end

    # @param [Class] type
    # @param [Object] object
    def expect_type(type, object)
      unless object.is_a?(type)
        raise TypeError, "expected #{type}, got #{object.class}"
      end
    end

  end
end # module
