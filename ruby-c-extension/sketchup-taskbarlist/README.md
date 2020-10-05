# TaskbarProgress

This is a SketchUp Ruby C++ Extension providing a wrapper around ITaskbarList3
that was introduced to Windows 7.

It is advised to read up on the interface for how to use it:
https://docs.microsoft.com/en-gb/windows/win32/api/shobjidl_core/nn-shobjidl_core-itaskbarlist3

## Visual Studio 2019

The Ruby C Extension was created with Visual Studio 2019:
https://visualstudio.microsoft.com/downloads/

## Examples

```ruby
require 'sketchup.rb'
require 'testup/taskbar_progress.rb'

model = Sketchup.active_model
entities = model.active_entities

TestUp::TaskbarProgress.new.each(entities.to_a) { |entity|
  entity.erase! if entity.valid?
}
```

```ruby
x = [1, 2, 3, 4, 5, 6]
progress = TestUp::TaskbarProgress.new
progress.each(x) { |entity|
  p x
  sleep(0.5)
}
```

```ruby
progress = TestUp::TaskbarProgress.new
progress.set_state(TestUp::TaskbarProgress::TBPF_INDETERMINATE)
```
