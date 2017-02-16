#-------------------------------------------------------------------------------
#
# Copyright 2013-2016 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'fileutils'


module TestUp
module SystemFiles

  if Sketchup.platform == :platform_win
    path = ENV['APPDATA'].to_s.dup
    path.force_encoding('UTF-8') if path.respond_to?(:force_encoding)
    APP_DATA_PATH = File.expand_path(path)
  else
    home = File.expand_path(ENV['HOME'].to_s)
    APP_DATA_PATH = File.join(home, 'Library', 'Application Support')
  end

  def app_data(app_name, *paths)
    File.join(APP_DATA_PATH, app_name, *paths)
  end

  def ensure_exist(path)
    unless File.directory?(path)
      FileUtils.mkdir_p(path)
    end
    path
  end

end # module
end # module TestUp
