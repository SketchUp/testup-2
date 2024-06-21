#-------------------------------------------------------------------------------
#
# Copyright 2013-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

module TestUp
  module Execution

    def self.delay(seconds, &block)
      done = false
      UI.start_timer(seconds, false) do
        next if done
        done = true
        yield
      end
    end

    def self.defer(&block)
      self.delay(0.0, &block)
    end

  end
end # module TestUp
