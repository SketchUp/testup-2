# This file accepts two arguments which specify which SketchUp version to load.
#   1. SketchUp version
#   2. Bitness (optional)
# Example: ruby debug-sketchup.rb 16 32
sketchup_version = ARGV[0].to_i
bitness = ARGV[1].to_i

# TODO: Need to set up Mac variant of this.
program_files_32 = ENV['ProgramFiles(x86)'] || 'C:/Program Files (x86)'
program_files_64 = ENV['ProgramW6432'] || 'C:/Program Files'

if bitness == 32
  program_files = program_files_32
else
  program_files = program_files_64
end

# Debugging only possible in SketchUp 2014 and newer as debugger protocol was
# introduced for Ruby 2.0.
version = "20#{sketchup_version}"

sketchup_path = File.join(program_files, 'SketchUp', "SketchUp #{version}")
sketchup = File.join(sketchup_path, 'SketchUp.exe')

# We then start SketchUp with the special flag to make it connect to the
# debugger on the given port.
command = %{"#{sketchup}" -rdebug "ide port=7000"}
spawn(command)
