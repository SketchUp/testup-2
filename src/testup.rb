#-------------------------------------------------------------------------------
#
# Copyright 2013-2016 Trimble Navigation Ltd.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

if defined?(Sketchup)
  require 'sketchup.rb'
  require 'extensions.rb'
elsif defined?(Layout)
  require 'layout.rb'
end

#-------------------------------------------------------------------------------

module TestUp

  ### CONSTANTS ### ------------------------------------------------------------

  # Plugin information
  PLUGIN_ID       = 'TestUp2'.freeze
  PLUGIN_NAME     = 'TestUp'.freeze
  PLUGIN_VERSION  = '2.2.0'.freeze

  # Resource paths
  FILENAMESPACE = File.basename(__FILE__, '.*')
  PATH_ROOT     = File.dirname(__FILE__).freeze
  PATH          = File.join(PATH_ROOT, FILENAMESPACE).freeze


  ### EXTENSION ### ------------------------------------------------------------

  loader = File.join( PATH, 'core.rb' )
  if defined?(Sketchup)
    if !file_loaded?(__FILE__)
      ex = SketchupExtension.new(PLUGIN_NAME, loader)
      ex.description = 'Test suite utility for SketchUp.'
      ex.version     = PLUGIN_VERSION
      ex.copyright   = 'Trimble Navigation Limited © 2016'
      ex.creator     = 'SketchUp'
      Sketchup.register_extension(ex, true)
      file_loaded(__FILE__)
    end
  else
    # LayOut doesn't have an SketchupExtensions class so the extension is loaded
    # directly. This should be updated if LayOut add a similar mechanism.
    require loader
  end

end # module TestUp
