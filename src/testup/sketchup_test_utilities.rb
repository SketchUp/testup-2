# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


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
