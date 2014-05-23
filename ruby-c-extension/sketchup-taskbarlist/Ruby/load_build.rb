ruby_path = File.dirname(__FILE__)
src_path = File.join(ruby_path, 'src')
solution_path = File.expand_path( File.join(ruby_path, '..') )

# Load 64bit lib if needed.
pointer_size = ['a'].pack('P').size * 8
if pointer_size > 32
  solution_path = File.join(solution_path, 'x64')
end

$LOAD_PATH << src_path

require File.join(solution_path, BUILD, 'TaskbarProgress')
require 'taskbar_progress.rb'
require File.join(ruby_path, "example.rb")

puts "TaskbarProgress #{TaskbarProgress::CEXT_VERSION} (#{BUILD}) loaded!"
