#-------------------------------------------------------------------------------
#
# Copyright 2014, Trimble Navigation Limited
#
# This software is provided as an example of using the Ruby interface
# to SketchUp.
#
# Permission to use, copy, modify, and distribute this software for
# any purpose and without fee is hereby granted, provided that the above
# copyright notice appear in all copies.
#
# THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
#
#-------------------------------------------------------------------------------


module TestUp

  def self.init_ui
    return if file_loaded?(__FILE__)

    # Commands
    cmd = UI::Command.new('TestUp 2') {
      self.toggle_testup
    }
    cmd.tooltip = 'Open TestUp'
    cmd.status_bar_text = 'Open TestUp for running tests.'
    cmd.small_icon = File.join(PATH_IMAGES, 'bug.png')
    cmd.large_icon = File.join(PATH_IMAGES, 'bug.png')
    cmd.set_validation_proc {
      MF_CHECKED if self.window && self.window.visible?
    }
    cmd_toggle_testup = cmd

    cmd = UI::Command.new('Run tests in Ruby Console') {
      self.toggle_run_in_gui
    }
    cmd.tooltip = 'Run in Console'
    cmd.status_bar_text = 'Enable to output test results in the Ruby Console.'
    cmd.small_icon = File.join(PATH_IMAGES, 'console.png')
    cmd.large_icon = File.join(PATH_IMAGES, 'console.png')
    cmd.set_validation_proc {
      MF_CHECKED if !self.run_in_gui
    }
    cmd_toggle_run_tests_in_console = cmd

    cmd = UI::Command.new('Verbose Console Tests') {
      self.toggle_verbose_console_tests
    }
    cmd.tooltip = 'Verbose Console Tests'
    cmd.status_bar_text = 'Enable verbose test results in the Ruby Console.'
    cmd.small_icon = File.join(PATH_IMAGES, 'verbose.png')
    cmd.large_icon = File.join(PATH_IMAGES, 'verbose.png')
    cmd.set_validation_proc {
      flags = 0
      flags |= MF_GRAYED if self.run_in_gui
      flags |= MF_CHECKED if self.verbose_console_tests
      flags
    }
    cmd_toggle_verbose_console_tests = cmd

    cmd = UI::Command.new('Reload TestUp') {
      SKETCHUP_CONSOLE.clear
      window_visible = @window && @window.visible?
      @window.close if window_visible
      @window = TestUpWindow.new
      @window.show if window_visible
      puts "Reloaded #{self.reload} files!"
    }
    cmd.small_icon = File.join(PATH_IMAGES, 'arrow_refresh.png')
    cmd.large_icon = File.join(PATH_IMAGES, 'arrow_refresh.png')
    cmd_reload_testup = cmd

    cmd = UI::Command.new('Minitest Help') {
      self.display_minitest_help
    }
    cmd.small_icon = File.join(PATH_IMAGES, 'help.png')
    cmd.large_icon = File.join(PATH_IMAGES, 'help.png')
    cmd_display_minitest_help = cmd

    cmd = UI::Command.new('Run Tests') {
      self.run_tests
    }
    cmd.tooltip = 'Discover and run all tests.'
    cmd.status_bar_text = 'Discover and run all tests.'
    cmd_run_tests = cmd

    # Menus
    menu = UI.menu('Plugins').add_submenu(PLUGIN_NAME)
    menu.add_item(cmd_toggle_testup)
    menu.add_separator
    menu.add_item(cmd_toggle_run_tests_in_console)
    menu.add_item(cmd_toggle_verbose_console_tests)
    menu.add_separator
    menu.add_item(cmd_run_tests)
    menu.add_separator
    menu.add_item(cmd_reload_testup)
    menu.add_separator
    menu.add_item(cmd_display_minitest_help)

    # Toolbar
    toolbar = UI::Toolbar.new(PLUGIN_NAME)
    toolbar.add_item(cmd_toggle_testup)
    toolbar.add_separator
    toolbar.add_item(cmd_toggle_run_tests_in_console)
    toolbar.add_item(cmd_toggle_verbose_console_tests)
    toolbar.add_separator
    toolbar.add_item(cmd_reload_testup)
    toolbar.add_separator
    toolbar.add_item(cmd_display_minitest_help)
    toolbar.restore

    # Ensure this method is run only once.
    file_loaded(__FILE__)
  end

end # module
