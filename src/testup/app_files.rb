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

  include SystemFiles

  def log_path
    ensure_exist(app_data(PLUGIN_NAME, 'Logs'))
  end

  def saved_runs_path
    ensure_exist(app_data(PLUGIN_NAME, 'Saved Runs'))
  end

end # module
end # module TestUp
