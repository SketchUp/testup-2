# TaskbarProgress

This is a SketchUp Ruby C++ Extension providing a wrapper around ITaskbarList3
that was introduced to Windows 7.

It is adviced to read up on the interface for how to use it:
http://msdn.microsoft.com/en-us/library/windows/desktop/dd391692(v=vs.85).aspx

## Visual Studio 2013

The Ruby C Extension was created with Visual Studio 2013:
http://www.visualstudio.com/downloads/download-visual-studio-vs

NOTE: The Ruby `config.h` had to be modified because it was originally intended
for Visual Studio 2010.

## Example

```ruby
require 'sketchup.rb'
require 'taskbar_progress.rb'

model = Sketchup.active_model
entities = model.active_entities

TaskbarProgress.new.each(entities.to_a) { |entity|
  entity.erase!
}
```
