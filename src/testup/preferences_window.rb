#-------------------------------------------------------------------------------
#
# Copyright 2013-2014 Trimble Navigation Ltd.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------


module TestUp
  class PreferencesWindow < SKUI::Window

    def initialize
      options = {
        :title           => "#{PLUGIN_NAME} - Preferences",
        :preferences_key => "#{PLUGIN_ID}_Preferences",
        :width           => 600,
        :height          => 400,
        :resizable       => false
      }
      super(options)
      init_controls()
    end

    # TODO: Fix this in SKUI.
    # Hack, as SKUI currently doesn't support subclassing of it's controls.
    def typename
      SKUI::Window.to_s.split('::').last
    end

    private

    def init_controls()
      # Test Suite Paths

      paths = TestUp.settings[:paths_to_testsuites]
      lst_paths = SKUI::Listbox.new(paths)
      lst_paths.name = :paths
      lst_paths.size = 10
      lst_paths.multiple = true
      lst_paths.position(5, 25)
      lst_paths.right = 5
      lst_paths.height = 150
      self.add_control(lst_paths)

      lbl_paths = SKUI::Label.new('Test suite paths:', lst_paths)
      lbl_paths.position(5, 5)
      self.add_control(lbl_paths)

      btn_move_up = SKUI::Button.new('Up') { |control|
        list = control.window[:paths]
        list.move_selected_up()
      }
      btn_move_up.position(5, 180)
      self.add_control(btn_move_up)

      btn_move_down = SKUI::Button.new('Down') { |control|
        list = control.window[:paths]
        list.move_selected_down()
      }
      btn_move_down.position(85, 180)
      self.add_control(btn_move_down)

      btn_edit_path = SKUI::Button.new('Edit') { |control|
        list = control.window[:paths]
        if list.value.nil?
          UI.beep
          next
        end
        directory = list.value.first
        path = SystemUI.select_directory(directory: directory)
        unless path.nil?
          index = list.index(directory)
          list.rename(index, path)
        end
      }
      btn_edit_path.position(-170, 180)
      self.add_control(btn_edit_path)

      btn_remove_path = SKUI::Button.new('Remove') { |control|
        list = control.window[:paths]
        for item in list.value.dup
          list.remove_item( item )
        end
      }
      btn_remove_path.position(-85, 180)
      self.add_control(btn_remove_path)

      btn_add_path = SKUI::Button.new('Add') { |control|
        message = 'Select folder that includes the test cases.'
        paths = SystemUI.select_directory(
          select_multiple: true,
          message: message
        )
        unless paths.nil?
          list = control.window[:paths]
          paths.each { |path|
            list.add_item(path)
          }
        end
      }
      btn_add_path.position(-5, 180)
      self.add_control(btn_add_path)

      # Code Editor

      grp_editor = SKUI::Groupbox.new('Code Editor')
      grp_editor.position(5, 220)
      grp_editor.right = 5
      grp_editor.height = 130
      self.add_control(grp_editor)

      txt_application = SKUI::Textbox.new(Editor.application)
      txt_application.name = :application
      txt_application.position(100, 30)
      txt_application.width = 400
      grp_editor.add_control(txt_application)

      lbl_application = SKUI::Label.new('Application:', txt_application)
      lbl_application.position(5, 32)
      lbl_application.width = 90
      lbl_application.align = :right
      grp_editor.add_control(lbl_application)

      txt_arguments = SKUI::Textbox.new(Editor.arguments)
      txt_arguments.name = :arguments
      txt_arguments.position(100, 60)
      txt_arguments.width = 400
      grp_editor.add_control(txt_arguments)

      lbl_arguments = SKUI::Label.new('Arguments:', txt_arguments)
      lbl_arguments.position(5, 62)
      lbl_arguments.width = 90
      lbl_arguments.align = :right
      grp_editor.add_control(lbl_arguments)

      lbl_argument_help = SKUI::Label.new('Variables: {FILE} {LINE}')
      lbl_argument_help.position(100, 85)
      lbl_argument_help.width = 400
      grp_editor.add_control(lbl_argument_help)


      # Dialog Save and Cancel

      btn_cancel = SKUI::Button.new('Cancel') { |control|
        control.window.close
      }
      btn_cancel.position(-85, -5)
      self.add_control(btn_cancel)

      btn_save = SKUI::Button.new('Save') { |control|
        paths = control.window[:paths].items
        application = control.window[:application].value
        arguments = control.window[:arguments].value
        if TestUp.settings[:paths_to_testsuites] != paths
          TestUp.settings[:paths_to_testsuites] = paths
          TestUp.window.reload
        end
        Editor.change(application, arguments)
        control.window.close
      }
      btn_save.position(-5, -5)
      self.add_control(btn_save)

      self.cancel_button = btn_cancel
      self.default_button = btn_save
    end

  end # class
end # module
