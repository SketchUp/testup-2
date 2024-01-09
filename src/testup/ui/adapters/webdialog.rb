#-------------------------------------------------------------------------------
#
# Copyright 2013-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'json'

require 'testup/ui/adapters/adapter'


module TestUp
  class WebDialogAdapter < UI::WebDialog

    include Adapter

    def show
      if Sketchup.platform == :platform_osx
        # UI::WebDialogs under mac isn't really modal. But this prevents the
        # dialog from disappearing behind the SketchUp window.
        show_modal
      else
        super
      end
    end

    # @return [Hash]
    def register_callback(callback_name, &block)
      add_action_callback(callback_name) { |dialog, have_params|
        # This assumes that `params_string` is a JSON string with an array
        # of objects.
        begin
          param = []
          if have_params && !have_params.empty?
            params_string = dialog.get_element_value('suBridge')
            params = params_string.empty? ? [] : JSON.parse(params_string)
          end
          yield dialog, *params
        rescue JSON::ParserError
          p [callback_name, params_string]
          raise
        end
      }
    end

  end # class
end # module
