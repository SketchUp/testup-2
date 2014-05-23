# Load the C Extension if the platform support it.
if Sketchup.platform == :platform_win
  # Guard required because when debugging from Visual Studio the extensions is
  # pre-loaded.
  unless defined?(TaskbarProgress::CEXT_VERSION)
    require_relative('lib/TaskbarProgress')
  end
end

class TaskbarProgress

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
      block.call(object)
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
