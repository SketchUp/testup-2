# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


module TestUp
 module Editor

  EXTRACT_PATTERN = /^"([^"]+)"\s+"([^"]+)"$/

  def self.application
    result = TestUp.settings[:editor].match(EXTRACT_PATTERN)
    return nil if result.nil?
    result[1]
  end

  def self.arguments
    result = TestUp.settings[:editor].match(EXTRACT_PATTERN)
    return nil if result.nil?
    result[2]
  end

  def self.change(application, arguments)
    TestUp.settings[:editor] = %["#{application}" "#{arguments}"]
  end

  def self.reset
    TestUp.settings[:editor] = self.get_default
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
      application = "subl"
    end
    arguments = '{FILE}:{LINE}'
    %["#{application}" "#{arguments}"]
  end

  # @param [String] file
  # @param [Integer] line
  def self.open_file(file, line = 0)
    editor = self.application
    arguments = self.arguments
    arguments.gsub!('{FILE}', file)
    arguments.gsub!('{LINE}', line)
    command = %["#{editor}" "#{arguments}"]
    system(command)
  end

 end # module
end # module TestUp
