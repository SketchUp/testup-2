# TaskbarProgress

This is a SketchUp Ruby C++ Extension providing a wrapper around ITaskbarList3
that was introduced to Windows 7.

It is advised to read up on the interface for how to use it:
https://docs.microsoft.com/en-gb/windows/win32/api/shobjidl_core/nn-shobjidl_core-itaskbarlist3

## Visual Studio 2013

The Ruby C Extension was created with Visual Studio 2019:
https://visualstudio.microsoft.com/downloads/

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
