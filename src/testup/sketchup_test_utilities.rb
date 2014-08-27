#-------------------------------------------------------------------------------
#
# Copyright 2013-2014 Trimble Navigation Ltd.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------


module TestUp

  class MenuGuard

    # Return a top level menu wrapped in a menu guard that prevent the menus
    # from being created multiple times.
    def self.menu(title)
      @@menus ||= {}
      unless @@menus.key?(title)
        @@menus[title] = self.new( UI.menu(title) )
      end
      @@menus[title]
    end

    def initialize(menu)
      @menu = menu
      @guarded_menus = {}
    end

    def add_item(title, &block)
      unless @guarded_menus.key?(title)
        menu = @menu.add_item(title, &block)
        guarded_menu = self.class.new(menu)
        @guarded_menus[title] = guarded_menu
      end
      @guarded_menus[title]
    end

    def add_separator
      # No need for test code to add separators. They would be hard to ensure
      # no duplicates.
    end

    def add_submenu(title)
      unless @guarded_menus.key?(title)
        menu = @menu.add_submenu(title)
        guarded_menu = self.class.new(menu)
        @guarded_menus[title] = guarded_menu
      end
      @guarded_menus[title]
    end

  end # class MenuGuard


  module SketchUpTestUtilities

    SKETCHUP_UNIT_TOLERANCE  = 1.0e-3
    SKETCHUP_FLOAT_TOLERANCE = 1.0e-10
    SKETCHUP_RANGE_MAX = -1.0e30
    SKETCHUP_RANGE_MIN =  1.0e30

    def start_with_empty_model
      model = Sketchup.active_model
      model.start_operation('TestUp Empty Model', true)
      while model.close_active; end
      for entity in model.entities.to_a
        entity.locked = false if entity.respond_to?(:locked=) && entity.locked?
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

    def open_new_model
      model = Sketchup.active_model
      if model.respond_to?(:close)
        # Suppress dialog boxes due to model changes.
        model.close(true)
        if Sketchup.platform == :platform_osx
          Sketchup.file_new
        end
      else
        Sketchup.file_new
      end
    end

    def discard_model_changes
      model = Sketchup.active_model
      if model.respond_to?(:close)
        model.close(true)
        if Sketchup.platform == :platform_osx
          Sketchup.file_new
        end
      end
    end

    def close_active_model
      model = Sketchup.active_model
      if model.respond_to?(:close)
        model.close(true)
      end
    end

    def disable_read_only_flag_for_test_models
      return false if Test.respond_to?(:suppress_warnings=)
      source = caller_locations(1,1)[0].absolute_path
      path = File.dirname(source)
      basename = File.basename(source, ".*")
      support_path = File.join(path, basename)
      skp_model_filter = File.join(support_path, '*.skp')
      @read_only_files = []
      Dir.glob(skp_model_filter) { |file|
        if !File.writable?(file)
          @read_only_files << file
          FileUtils.chmod("a+w", file)
        end
      }
      true
    end

    def restore_read_only_flag_for_test_models
      return false if Test.respond_to?(:suppress_warnings=)
      source = caller_locations(1,1)[0].absolute_path
      path = File.dirname(source)
      basename = File.basename(source, ".*")
      support_path = File.join(path, basename)
      skp_model_filter = File.join(support_path, '*.skp')
      @read_only_files.each { |file|
        FileUtils.chmod("a-w", file)
      }
      @read_only_files.clear
      true
    end

  end # module

end # module
