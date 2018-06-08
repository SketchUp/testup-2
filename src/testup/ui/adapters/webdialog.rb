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

    # @return [Hash]
    def register_callback(callback_name, &block)
      add_action_callback(callback_name) { |dialog, params_string|
        # This assumes that `params_string` is a JSON string with an array
        # of objects.
        params = JSON.parse(params_string)
        block.call(dialog, *params)
      }
    end

  end # class
end # module
