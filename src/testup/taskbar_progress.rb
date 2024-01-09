#-------------------------------------------------------------------------------
#
# Copyright 2013-2014 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------


module TestUp
 class TaskbarProgress

  # Load the C Extension if the platform support it.
  if RUBY_PLATFORM =~ /mswin|mingw/
    # Guard required because when debugging from Visual Studio the extensions is
    # pre-loaded.
    unless defined?(CEXT_VERSION)
      pointer_size = ['a'].pack('P').size * 8
      major, minor, rev = RUBY_VERSION.split('.')
      ruby = "ruby#{major}#{minor}0"
      begin
        if pointer_size > 32
          require_relative("lib/#{ruby}/x64/TaskbarProgress")
        else
          require_relative("lib/#{ruby}/x86/TaskbarProgress")
        end
      rescue LoadError => error
        # Soft fail when the lib cannot be loaded. It's just extra visuals.
        puts 'Failed to load TaskbarProgress'
        puts error.message
        # puts error.backtrace.join("\n")
        puts 'Ignoring...'
      end
    end
  end

  # If the platform is not supported add noop methods to avoid errors.
  unless defined?(CEXT_VERSION)

    NOPROGRESS    = :platform_unsupported
    INDETERMINATE = :platform_unsupported
    NORMAL        = :platform_unsupported
    ERROR         = :platform_unsupported
    PAUSED        = :platform_unsupported

    def set_state(*args); end
    def set_value(*args); end

  end

  # Utility method that takes care of updating the progressbar as it iterates
  # the given collection.
  #
  # @param [Enumerable] collection
  # @return [Mixed] The result of `collection.each`.
  def each(collection, &block)
    total = get_collection_size(collection)
    set_state(NORMAL)
    result = collection.each_with_index { |object, index|
      set_value(index, total)
      yield object
    }
    result
  ensure
    set_state(NOPROGRESS)
  end

  private

  # @param [Enumerable] collection
  # @return [Integer]
  def get_collection_size(collection)
    # `count` is much slower than `size` or `length`.
    if collection.respond_to?(:size)
      total = collection.size
    elsif collection.respond_to?(:length)
      total = collection.size
    else
      # NOTE: Not availible under Ruby 1.8.
      total = collection.count
    end
    total
  end

 end # class
end # module
