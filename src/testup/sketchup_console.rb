# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen

# TODO(thomthom) These modifications should ideally be implemented officially
# in our Ruby API.

# In order to run in the SketchUp Ruby console there needs to be more methods
# similar to the IO class. The methods are implemented as needed and behaviour
# is copied from the IO class.
class Sketchup::Console

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
    # no use. Currently raising an exception in case the MiniTest framework
    # should depend on setting sync to false.
    # However, it looks like it only tries to set it to true.
    unless value
      raise "#{self.class} doesn't support changing sync."
    end
  end

end # class Sketchup::Console
