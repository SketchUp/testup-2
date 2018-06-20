#-------------------------------------------------------------------------------
#
# Copyright 2013-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'testup/config'
require 'testup/taskbar_progress'


module TestUp
  module Log

    keys = (TestUp.settings[:tracing] || []).map(&:to_sym)
    @trace = Hash[keys.map { |key| [key, true] }]

    # @return [Array<Symbol>]
    def self.trace_categories
      @trace.keys
    end

    # @param [Symbol] category
    # @param [Boolean] enabled
    def self.set_tracing(category, enabled)
      @trace[category] = enabled
      # Sketchup.write/read_default doesn't handle Symbols. So write them out
      # as strings instead.
      TestUp.settings[:tracing] = @trace.select { |k,v| v }.keys.map(&:to_s)
      nil
    end

    def self.info(*args)
      puts(*args)
    end

    def self.debug(*args)
      puts(*args) if debug?
    end

    def self.warn(*args)
      print '[Warning]: '
      puts(*args)
    end

    def self.debug?
      TestUp.settings[:debug]
    end

    # @param [Symbol] category
    def self.trace(category, *args)
      @trace[category] = false unless @trace.key?(category) # Track keys used
      puts(*args) if @trace[category]
    end

  end # module
end # module
