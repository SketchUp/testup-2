#-------------------------------------------------------------------------------
#
# Copyright 2013-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'testup/ui/adapters/adapter'


module TestUp
  class HtmlDialogAdapter < UI::HtmlDialog

    include Adapter

    # @return [Hash]
    def register_callback(callback_name, &block)
      add_action_callback(callback_name, &block)
    end

  end # class
end # module
