#-------------------------------------------------------------------------------
#
# Copyright 2013-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'testup/taskbar_progress'


module TestUp
  module Log

    @debug = true

    @trace = {
      discover: false, # TODO: Make configurable.
    }
    def self.set_tracing(category, enabled)
      @trace[category] = enabled
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
      @debug
    end

    def self.trace(category, *args)
      puts(*args) if @trace[category]
    end

  end # module
end # module
