# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


module TestUp

  module SketchUpTestUtilities

    def start_with_empty_model
      model = Sketchup.active_model
      model.entities.clear!
      model
    end

  end # module

end # module
