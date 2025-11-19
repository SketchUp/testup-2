#-------------------------------------------------------------------------------
#
# Copyright 2013-2016 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'fileutils'
require 'testup/system_files.rb'


module TestUp
module AppFiles
  module Impl

    extend SystemFiles

    def self.log_path
      @log_path ||= default_log_path
      ensure_exist(@log_path)
    end

    def self.log_path=(path)
      @log_path = path
    end


    def self.saved_runs_path
      @saved_runs_path ||= default_saved_runs_path
      ensure_exist(@saved_runs_path)
    end

    def self.saved_runs_path=(path)
      @saved_runs_path = path
    end


    def self.default_log_path
      app_data(PLUGIN_NAME, 'Logs')
    end

    def self.default_saved_runs_path
      app_data(PLUGIN_NAME, 'Saved Runs')
    end

  end

  include SystemFiles

  def log_path
    Impl.log_path
  end

  def log_path=(path)
    Impl.log_path = path
  end


  def saved_runs_path
    Impl.saved_runs_path
  end

  def saved_runs_path=(path)
    Impl.saved_runs_path = path
  end

end # module
end # module TestUp
