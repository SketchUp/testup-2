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
      self.open_testup
    }
    cmd.tooltip = 'Open TestUp'
    cmd.status_bar_text = 'Open TestUp for running tests.'
    cmd.small_icon = File.join(PATH_IMAGES, 'bug.png')
    cmd.large_icon = File.join(PATH_IMAGES, 'bug.png')
    cmd_open_testup = cmd

    cmd = UI::Command.new('Run tests in Ruby Console') {
      self.run_tests
    }
    cmd.tooltip = 'Run in Console'
    cmd.status_bar_text = 'Run tests in Ruby Console.'
    cmd.small_icon = File.join(PATH_IMAGES, 'console.png')
    cmd.large_icon = File.join(PATH_IMAGES, 'console.png')
    cmd_run_console_tests = cmd

    cmd = UI::Command.new('Reload TestUp') {
      SKETCHUP_CONSOLE.clear
      window_visible = @window && @window.visible?
      @window.close if window_visible
      @window = nil
      self.open_testup if window_visible
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
    menu.add_item(cmd_open_testup)
    menu.add_item(cmd_run_console_tests)
    menu.add_separator
    menu.add_item(cmd_run_tests)
    menu.add_separator
    menu.add_item(cmd_reload_testup)
    menu.add_separator
    menu.add_item(cmd_display_minitest_help)

    # Toolbar
    toolbar = UI::Toolbar.new(PLUGIN_NAME)
    toolbar.add_item(cmd_open_testup)
    toolbar.add_item(cmd_run_console_tests)
    toolbar.add_separator
    toolbar.add_item(cmd_reload_testup)
    toolbar.add_separator
    toolbar.add_item(cmd_display_minitest_help)
    toolbar.restore

    # Ensure this method is run only once.
    file_loaded(__FILE__)
  end

end # module
