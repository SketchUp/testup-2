TestUp 2 for SketchUp
=====================

Requirements
------------

1. Windows (OSX currently need Ruby API improvements)

2. Visual C++ Redistributable Packages for Visual Studio 2013
http://www.microsoft.com/en-us/download/details.aspx?id=40784

Setup for Contributing
----------------------

1. Fork the project to your own GitHub account. This is important so that we can do code review on changes done. No NOT push directly to the main repo.

2. Clone your fork to your computer.

3. Add a helper Ruby file in your Plugins folder:

**load_testup.rb**
```ruby
# This adds the source directory to Ruby's search path and
# loads TestUp 2.
$LOAD_PATH << "C:/Users/YourUserName/Documents/testup-2/src"
require "testup2.rb"
```
