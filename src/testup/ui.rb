#-------------------------------------------------------------------------------
#
# Copyright 2013-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'testup/command'
require 'testup/config'
require 'testup/runs'


module TestUp

  # @param [Sketchup::Menu] menu
  # @param [Symbol] category
  def self.add_tracing_toggle(menu, category)
    item = menu.add_item("Toggle Tracing: #{category}") {
      setting = !TestUp::Log.tracing(category)
      TestUp::Log.set_tracing(category, setting)
    }
    menu.set_validation_proc(item) {
      TestUp::Log.tracing(category) ? MF_CHECKED : MF_ENABLED
    }
  end

  def self.init_ui
    return if file_loaded?(__FILE__)

    # Commands
    cmd = Command.new('Open TestUp') {
      self.toggle_test_runner_window
    }
    cmd.tooltip = 'Open TestUp'
    cmd.status_bar_text = 'Open TestUp for running tests.'
    cmd.icon = File.join(PATH_IMAGES, 'testup')
    cmd.set_validation_proc {
      self.window && self.window.visible? ? MF_CHECKED : MF_ENABLED
    } if defined?(Sketchup)
    cmd_toggle_testup = cmd

    cmd = Command.new('Run tests in Ruby Console') {
      self.toggle_run_in_gui
    }
    cmd.tooltip = 'Run in Console'
    cmd.status_bar_text = 'Enable to output test results in the Ruby Console.'
    cmd.icon = File.join(PATH_IMAGES, 'console')
    cmd.set_validation_proc {
      self.settings[:run_in_gui] ? MF_ENABLED : MF_CHECKED
    } if defined?(Sketchup)
    cmd_toggle_run_tests_in_console = cmd

    cmd = Command.new('Custom Seed') {
      self.set_custom_seed
    }
    cmd.tooltip = 'Tests Running Order'
    cmd.status_bar_text = 'Set custom seed for running tests.'
    cmd.icon = File.join(PATH_IMAGES, 'random')
    cmd.set_validation_proc {
      self.settings[:seed] ? MF_ENABLED : MF_CHECKED
    } if defined?(Sketchup)
    cmd_seed = cmd

    cmd = Command.new('Re-run Saved Run') {
      self::Runs.rerun_current
    }
    cmd.tooltip = 'Re-run a Saved Run from a previously picked .run file.'
    cmd.status_bar_text = 'Re-run a Saved Run from a previously picked .run file.'
    cmd.icon = File.join(PATH_IMAGES, 'rerun')
    cmd.set_validation_proc {
      self::Runs.current ? MF_ENABLED : MF_GRAYED
    } if defined?(Sketchup)
    cmd_rerun_saved = cmd

    cmd = Command.new('Verbose Console Tests') {
      self.toggle_verbose_console_tests
    }
    cmd.tooltip = 'Verbose Console Tests'
    cmd.status_bar_text = 'Enable verbose test results in the Ruby Console.'
    cmd.set_validation_proc {
      flags = 0
      flags |= MF_GRAYED if self.settings[:run_in_gui]
      flags |= MF_CHECKED if self.settings[:verbose_console_tests]
      flags
    } if defined?(Sketchup)
    cmd_toggle_verbose_console_tests = cmd

    cmd = Command.new('Open Log Folder') {
      self.open_log_folder
    }
    cmd.tooltip = 'Open folder with logs'
    cmd.status_bar_text = 'Open folder with logs.'
    cmd_open_logs = cmd

    cmd = Command.new('Open Console on Startup') {
      self.settings[:open_console_on_startup] = !self.settings[:open_console_on_startup]
    }
    cmd.tooltip = 'Open Console on Startup'
    cmd.status_bar_text = 'Open Console on Startup.'
    cmd.set_validation_proc {
      self.settings[:open_console_on_startup] ? MF_CHECKED : MF_ENABLED
    } if defined?(Sketchup)
    cmd_open_console_on_startup = cmd

    cmd = Command.new('Reload TestUp') {
      TESTUP_CONSOLE.clear
      window_visible = @window && @window.visible?
      @window.close if window_visible
      @window = TestUpWindow.new
      @window.show if window_visible
      puts "Reloaded #{self.reload} files!"
    }
    cmd.tooltip = 'Reload TestUp'
    cmd.small_icon = File.join(PATH_IMAGES, 'arrow_refresh.png')
    cmd.large_icon = File.join(PATH_IMAGES, 'arrow_refresh.png')
    cmd_reload_testup = cmd

    cmd = Command.new('Minitest Help') {
      self.display_minitest_help
    }
    cmd.tooltip = 'Minitest Help'
    cmd_display_minitest_help = cmd

    cmd = Command.new('Force WebDialog') {
      if self.settings[:window_adapter] == 'web_dialog'
        self.settings[:window_adapter] = nil
      else
        self.settings[:window_adapter] = 'web_dialog'
      end
      self.reset_dialogs
    }
    cmd.tooltip = 'Force WebDialog'
    cmd.status_bar_text = 'Force WebDialog.'
    cmd.set_validation_proc {
      self.settings[:window_adapter] == 'web_dialog' ? MF_CHECKED : MF_ENABLED
    } if defined?(Sketchup)
    cmd_debug_force_webdialog = cmd


    # Menus
    if defined?(Sketchup)
      menu = UI.menu('Plugins').add_submenu(PLUGIN_NAME)
      menu.add_item(cmd_toggle_testup)
      menu.add_separator
      menu.add_item(cmd_seed)
      menu.add_separator
      sub_menu = menu.add_submenu('Saved Runs')
      menu_id = sub_menu.add_item('Set Replay-Run') { self::Runs.set_current }
      sub_menu.set_validation_proc(menu_id) {
        self::Runs.current ? MF_CHECKED : MF_ENABLED
      }
      sub_menu.add_separator
      sub_menu.add_item(cmd_rerun_saved)
      sub_menu.add_separator
      sub_menu.add_item('Add Run...') { self::Runs.add }
      sub_menu.add_item('Remove Run...') { self::Runs.remove }
      menu.add_separator
      menu.add_item(cmd_open_console_on_startup)
      menu.add_item(cmd_toggle_run_tests_in_console)
      menu.add_item(cmd_toggle_verbose_console_tests)
      menu.add_separator
      sub_menu = menu.add_submenu('Debug')
      sub_menu.add_item(cmd_display_minitest_help)
      sub_menu.add_separator
      sub_menu.add_item(cmd_open_logs)
      sub_menu.add_separator
      sub_menu.add_item(cmd_debug_force_webdialog)
      sub_menu.add_separator
      sub_menu.add_item(cmd_reload_testup)
      sub_menu.add_separator
      add_tracing_toggle(sub_menu, :call_js)
      add_tracing_toggle(sub_menu, :callback)
      add_tracing_toggle(sub_menu, :discover)
      add_tracing_toggle(sub_menu, :minitest)
      add_tracing_toggle(sub_menu, :timing)
    end

    # Toolbar
    if defined?(Sketchup)
      toolbar = UI::Toolbar.new(PLUGIN_NAME)
      toolbar.add_item(cmd_toggle_testup)
      toolbar.add_separator
      toolbar.add_item(cmd_seed)
      toolbar.add_separator
      toolbar.add_item(cmd_rerun_saved)
      toolbar.add_separator
      toolbar.add_item(cmd_toggle_run_tests_in_console)
      if TestUp::DEBUG
        toolbar.add_separator
        toolbar.add_item(cmd_reload_testup)
      end
      toolbar.restore
    end

    # Ensure this method is run only once.
    file_loaded(__FILE__)
  end


  module SystemUI

    def self.select_directory(options)
      if defined?(UI) && UI.respond_to?(:select_directory)
        result = UI.select_directory(options)
        return nil if result.nil?
        if options && options[:select_multiple]
          result.map! { |path| File.expand_path(path) }
        else
          result = File.expand_path(result)
        end
        result
      else
        self.select_directory_fallback(options)
      end
    end

    BIF_RETURNONLYFSDIRS = 0x00000001
    BIF_EDITBOX = 0x00000010
    BIF_NEWDIALOGSTYLE = 0x00000040
    BIF_UAHINT = 0x00000100

    def self.select_directory_fallback(options)
      unless RUBY_PLATFORM =~ /mswin|mingw/
        warn 'select_directory_fallback not implemented for this platform'
        return nil
      end

      require 'win32ole'

      message = ''
      select_multiple = false
      if options
        message = options[:message] || message
        select_multiple = options[:select_multiple] || select_multiple
      end

      objShell = WIN32OLE.new('Shell.Application')
      parent_window = TestUp::Win32Helper.get_main_window_handle
      dialog_options = BIF_RETURNONLYFSDIRS | BIF_NEWDIALOGSTYLE | BIF_EDITBOX

      # http://msdn.microsoft.com/en-us/library/windows/desktop/bb774065(v=vs.85).aspx
      # noinspection RubyResolve
      objFolder = objShell.BrowseForFolder(parent_window, message, dialog_options)

      return nil if objFolder.nil?
      # noinspection RubyResolve
      path = objFolder.Self.Path
      unless File.exist?(path)
        UI.messagebox("Unable to handle '#{path}'.")
        return nil
      end
      directory = File.expand_path(path)

      if select_multiple
        [directory]
      else
        directory
      end
    end

  end # module SystemUI

end # module
