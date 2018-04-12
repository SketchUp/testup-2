#-------------------------------------------------------------------------------
#
# Copyright 2013-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'testup/taskbar_progress'


module TestUp
  module Log

    def self.info(*args)
      puts(*args)
    end

    def self.warn(*args)
      print '[Warning]: '
      puts(*args)
    end

  end # module
end # module
