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

    def capture_stdout(verbose = $VERBOSE, &block)
      io_buffer = StringIO.new
      stdout = $stdout
      $stdout = io_buffer
      set_verbose_mode(verbose) {
        block.call
      }
      io_buffer
    ensure
      $stdout = stdout
    end

    def capture_stderr(verbose = $VERBOSE, &block)
      io_buffer = StringIO.new
      stderr = $stderr
      $stderr = io_buffer
      set_verbose_mode(verbose) {
        block.call
      }
      io_buffer
    ensure
      $stderr = stderr
    end

    VERBOSE_SILENT = nil
    VERBOSE_SOME   = false # Default
    VERBOSE_ALL    = true
    def set_verbose_mode(mode, &block)
      verbose = $VERBOSE
      $VERBOSE = mode
      block.call
    ensure
      $VERBOSE = verbose
    end

  end # module


  module ObserverForwarder

    # Catch all notification events sent to the observer.
    def method_missing(method_sym, *arguments, &block)
      #puts "ObserverForwarder.method_missing(#{method_sym})"
      if method_sym.to_s =~ /^on[A-Z_]/
        #puts "=> #{method_sym} (method_missing trace)" if @trace_notifications
        _forward_callback(method_sym.to_s, *arguments)
      else
        super
      end
    end

    def self.included(base)
      # When the observer sub-classes a template observer we must inject
      # forwarding methods that will ensure all notifications is caught.
      #puts "ObserverForwarder.included"
      #p base.instance_methods.grep(/^on[A-Z_]/)
      base.instance_methods.grep(/^on[A-Z_]/).each { |symbol|
        #puts "Intercepting #{symbol}"
        base.class_eval {
          define_method(symbol) { |*args|
            #puts "=> #{symbol} (overloaded trace)" if @trace_notifications
            _forward_callback(symbol.to_s, *args)
            super(*args)
          } # define method
        }
      }
    end

    # It's important to know Object defines respond_to to take two parameters:
    # the method to check, and whether to include private methods
    # http://www.ruby-doc.org/core/classes/Object.html#M000333
    def respond_to?(method_sym, include_private = false)
      #puts "ObserverForwarder.respond_to?(#{method_sym})"
      if method_sym.to_s =~ /^on[A-Z_]/
        #puts "> Observer Event!"
        true
      else
        super
      end
    end

    def _start_notification_trace
      @trace_notifications = true
    end

    def _stop_notification_trace
      @trace_notifications = false
    end

    private

    def _set_forwarding_receiver(receiver)
      #puts "_set_forwarding_receiver (#{@receiver.inspect})"
      @receiver = receiver
    end

    def _forward_callback(callback_name, *args)
      #puts "#{callback_name} (#{@receiver.inspect})"
      return if @receiver.nil?
      @receiver.add_callback_data(callback_name, args)
    end

  end # module


  module ObserverReceiver

    # Make sure to call super from class that inherits!
    #def setup
    #  @@callback_data = nil
    #end

    # Make sure to call super from class that inherits!
    #def teardown
    #  @@callback_data = nil
    #end

    #def self.add_callback_data(method, data)
    #  @@callback_data ||= {}
    #  @@callback_data[method] ||= []
    #  @@callback_data[method] << data
    #end

    def self.included(base)
      base.send(:include, InstanceMethods)
      base.extend(ClassMethods)
    end

    #def reset_callback_data
    #  @@callback_data = nil
    #end
    #private :reset_callback_data

    module InstanceMethods

      def reset_callback_data
        self.class.reset_callback_data
      end

      def callback_data
        self.class.callback_data
      end

      def assert_notifications(*args)
        assert_kind_of(Hash, callback_data, "No notification received")
        args.each { |notification|
          was_called = callback_data.has_key?(notification)
          assert_equal(true, was_called, "#{notification} not called")
        }
        callback_data.each { |notification, arguments|
          expected = args.include?(notification)
          assert_equal(true, expected, "#{notification} unexpectedly called")
        }
      end

      def assert_no_notification
        num = callback_data ? callback_data.size : 0
        assert_nil(callback_data,
            "#{num} unexpected notifications")
      end

      # @param [String] event
      # @param [Integer] argument
      # @param [Class] type
      # @param [Object] expected
      def assert_callback_data(event, argument_index, type, expected)
        # NOTE: This inspects only the last callback.
        arguments = callback_data[event].last
        argument = arguments[argument_index]
        assert_kind_of(type, argument,
            "#{event} returned unexpected type for argument #{argument_index}")
        assert_equal(expected, argument,
            "#{event} returned unexpected value for argument #{argument_index}")
      end

      # @param [String] notification
      # @param [Object] expected
      def assert_notification_count(notification, expected)
        if callback_data.nil? || callback_data[notification].nil?
          actual = 0
        else
          actual = callback_data[notification].size
        end
        assert_equal(expected, actual,
            "#{notification} called unexpected number of times")
      end

    end # module

    module ClassMethods

      def add_callback_data(method, data)
        #puts "#{self}.add_callback_data(#{method})"
        return if method.to_s.start_with?("onDebug")
        @@callback_data ||= {}
        @@callback_data[method] ||= []
        @@callback_data[method] << data
      end

      def callback_data
        @@callback_data
      end

      def reset_callback_data
        #puts "!!! reset_callback_data !!!"
        @@callback_data = nil
      end

    end # module

  end # module

end # module
