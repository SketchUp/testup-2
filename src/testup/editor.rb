#-------------------------------------------------------------------------------
#
# Copyright 2013-2014 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

module TestUp
 module Editor

  # Legacy setting when it all was stored in a single string.
  EXTRACT_PATTERN = /^"([^"]+)"\s+"([^"]+)"$/

  def self.application
    setting = TestUp.settings[:editor_application]
    if setting.nil?
      setting = TestUp.settings[:editor]
      return nil unless setting.is_a?(String)
      # Legacy setting when it all was stored in a single string.
      result = string.match(EXTRACT_PATTERN)
      return nil if result.nil?
      result[1]
    else
      setting
    end
  end

  def self.arguments
    setting = TestUp.settings[:editor_arguments]
    if setting.nil?
      setting = TestUp.settings[:editor]
      return nil unless setting.is_a?(String)
      # Legacy setting when it all was stored in a single string.
      result = setting.match(EXTRACT_PATTERN)
      return nil if result.nil?
      result[2]
    else
      setting
    end
  end

  def self.change(application, arguments)
    TestUp.settings[:editor] = nil
    TestUp.settings[:editor_application] = application
    TestUp.settings[:editor_arguments] = arguments
    nil
  end

  def self.reset
    application, arguments = self.get_default
    self.change(application, arguments)
    [application, arguments]
  end

  # @return [String]
  def self.get_default
    # TODO: Detect common editor and make a 'guess' for default choice.
    if RUBY_PLATFORM =~ /mswin|mingw/
      program_files = File.expand_path(ENV['ProgramW6432'])
      application = File.join(program_files, 'Sublime Text 3','sublime_text.exe')
    else
      # OSX
      # http://www.sublimetext.com/docs/3/osx_command_line.html
      application = "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl"
    end
    arguments = '"{FILE}:{LINE}"'
    [application, arguments]
  end

  # @param [String] file
  # @param [Integer] line
  def self.open_file(file, line = 0)
    editor = self.application
    arguments = self.arguments
    arguments.gsub!('{FILE}', file)
    arguments.gsub!('{LINE}', line)
    command = %["#{editor}" #{arguments}]
    system(command)
  end

 end # module
end # module TestUp
