#-------------------------------------------------------------------------------
#
# Copyright 2013-2014 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'delegate'

# TODO(thomthom) These modifications should ideally be implemented officially
# in our Ruby API.

module TestUp

  # TODO(thomthom): Add LayOut console class.
  if defined?(Sketchup)
    APP_CONSOLE = SKETCHUP_CONSOLE
  elsif defined?(Layout)
    APP_CONSOLE = LAYOUT_CONSOLE # TODO(thomthom): Correct?
  end

  # In order to run in the SketchUp Ruby console there needs to be more methods
  # similar to the IO class. The methods are implemented as needed and behaviour
  # is copied from the IO class.
  # NOTE: These should be removed if SketchUp and/or LayOut implements them
  # nativly. Both applications should be in sync for the capabilities of the
  # console.
  class Console < SimpleDelegator

    # @param [Sketchup::Console] console
    def initialize(console = SKETCHUP_CONSOLE)
      __setobj__(console)
    end

    def write(*args)
      args.each { |arg|
        __getobj__.write(arg)
      }
    end

    def print(*args)
      if args.empty?
        write($_)
      else
        glue = $, || ''
        record_separator = $\ || ''
        output = args.join(glue) << record_separator
        write(output)
      end
      nil
    end

    def puts(*args)
      if args.empty?
        write $/
      else
        for arg in args
          line = arg.to_s
          write(line)
          if line.empty? || !line.end_with?($/)
            write($/)
          end
        end
      end
      nil
    end

    def sync=(value)
      # The SketchUp console always output immediately so setting to false is of
      # no use. Currently raising an exception in case the Minitest framework
      # should depend on setting sync to false.
      # However, it looks like it only tries to set it to true.
      unless value
        raise "#{self.class} doesn't support changing sync."
      end
    end

    def external_encoding
      Encoding::UTF_8
    end

  end # class Console

  TESTUP_CONSOLE = Console.new(APP_CONSOLE)

end # module TestUp
