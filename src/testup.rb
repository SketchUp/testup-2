#-------------------------------------------------------------------------------
#
# Copyright 2014, Trimble Navigation Limited
#
# This software is provided as an example of using the Ruby interface
# to SketchUp.
#
# Permission to use, copy, modify, and distribute this software for
# any purpose and without fee is hereby granted, provided that the above
# copyright notice appear in all copies.
#
# THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
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
  PLUGIN_NAME     = 'TestUp²'.freeze
  PLUGIN_VERSION  = '2.0.0'.freeze

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
      ex.copyright   = 'Trimble Navigation Limited © 2014'
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
