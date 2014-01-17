# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


module TestUp

  module SketchUpTestUtilities

    def start_with_empty_model
      model = Sketchup.active_model
      model.start_operation('TestUp Empty Model', true)
      while model.close_active; end
      for entity in model.entities.to_a
        entity.locked = false if entity.respond_to?(:locked=)
      end
      model.entities.clear!
      model.materials.current = nil
      model.active_layer = nil
      for page in model.pages.to_a
        model.pages.erase(page)
      end
      model.definitions.purge_unused
      model.materials.purge_unused
      model.layers.purge_unused
      model.styles.purge_unused
      # TODO(Remove schemas)
      model.commit_operation
      model
    end

  end # module

end # module
