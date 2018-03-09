#-------------------------------------------------------------------------------
#
# Copyright 2013-2014 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------


module TestUp
 class Settings

  # @param [String] settings_id
  def initialize(settings_id, defaults = {})
    @settings_id = settings_id
    @defaults = defaults
    # Cache data so we don't have to query the registry or plist all the time.
    # Some of these settings are queried by context menu handlers.
    @data = Hash.new { |hash, key|
      if defined?(Sketchup)
        Sketchup.read_default(@settings_id, key.to_s, @defaults[key])
      else
        @defaults[key]
      end
    }
  end

  def [](key)
    value = (@data[key].nil?) ? @defaults[key] : @data[key]
    (value.is_a?(String) || value.is_a?(Array)) ? value.dup : value
  end

  def []=(key, value)
    if defined?(Sketchup)
      escaped_value = escape_quotes(value)
      Sketchup.write_default(@settings_id, key.to_s, escaped_value)
    end
    @data[key] = value
  end

  def inspect
    to_s
  end

  private

  def escape_quotes(value)
    # TODO(thomthom): Include Hash? Likely value to store.
    if value.is_a?(String)
      value.gsub(/"/, '\\"')
    elsif value.is_a?(Array)
      value.map { |sub_value| escape_quotes(sub_value) }
    else
      value
    end
  end

 end # class
end # module TestUp
