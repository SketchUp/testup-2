module TestUp
  module SketchUpTests
    module Length

        # Convert a en-US locale unit string to the current machine locale.
        # @note The input should always use period as decimal separator.
        def u(string)
          # For some reason we never replaced the list separator.
          # string.tr(',', Sketchup::RegionalSettings.list_separator)
          str = string.tr('.', Sketchup::RegionalSettings.decimal_separator)
          # SketchUp 2019 adjusted how it formats metric units, adding a space
          # between the numbers and unit annotation.
          str.gsub!(/([0-9.]+)([cm]+)/, "\\1 \\2")
          str
        end

        # @param [String] expected
        # @param [String] actual
        def assert_unit(expected, actual, *args)
          assert_equal(u(expected), u(actual), *args)
        end

    end
  end
end