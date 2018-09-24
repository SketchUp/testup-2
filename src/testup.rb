#-------------------------------------------------------------------------------
#
# Copyright 2013-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

if defined?(Sketchup)
  require 'sketchup.rb'
  require 'extensions.rb'
elsif defined?(Layout)
  require 'layout.rb'
end

require 'json'

#-------------------------------------------------------------------------------

module TestUp

  ### CONSTANTS ### ------------------------------------------------------------

  # Resource paths
  FILENAMESPACE = File.basename(__FILE__, '.*')
  PATH_ROOT     = File.dirname(__FILE__).freeze
  PATH          = File.join(PATH_ROOT, FILENAMESPACE).freeze

  # Extension information
  extension_json_file = File.join(PATH, 'extension.json')
  extension_json = File.read(extension_json_file)
  EXTENSION = ::JSON.parse(extension_json, symbolize_names: true).freeze

  # Backward compatible constants. Prefer EXTENSION over these.
  PLUGIN_ID       = EXTENSION[:product_id].freeze
  PLUGIN_NAME     = EXTENSION[:name].freeze
  PLUGIN_VERSION  = EXTENSION[:version].freeze


  ### EXTENSION ### ------------------------------------------------------------

  loader = 'testup/core'
  if defined?(Sketchup)
    if !file_loaded?(__FILE__)
      ex = SketchupExtension.new(EXTENSION[:name], 'testup/core')
      ex.description = EXTENSION[:description]
      ex.version     = EXTENSION[:version]
      ex.copyright   = EXTENSION[:copyright]
      ex.creator     = EXTENSION[:creator]
      Sketchup.register_extension(ex, true)
      file_loaded(__FILE__)
    end
  else
    # LayOut doesn't have an SketchupExtensions class so the extension is loaded
    # directly. This should be updated if LayOut add a similar mechanism.
    require loader
  end

end # module TestUp
