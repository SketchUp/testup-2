module TestUp
  module SketchUpTests
    module ImageHelper

      def create_test_image
        entities = Sketchup.active_model.entities
        filename = File.join(__dir__, "../shared/99bugs.jpg")
        assert(File.exists?(filename), "File missing: #{filename}")
        image = Sketchup.active_model.entities.add_image(filename, ORIGIN, 1.m)
        image
      end

      def create_image_material
        image = create_test_image
        definition = image.model.definitions.find(&:image?)
        material = definition.entities.grep(Sketchup::Face).first.material
        material
      end

    end
  end
end
