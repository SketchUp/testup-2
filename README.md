TestUp 2 for SketchUp
=====================

Requirements
------------

1. SketchUp 2014 or newer.

Setup for Contributing
----------------------

1. Fork the project to your own GitHub account. This is important so that we can do code review on changes done.
_No **not** push directly to the main repository._

2. Clone your fork to your computer.

3. Add a helper Ruby file in your Plugins folder:

```ruby
# load_testup.rb
# This adds the source directory to Ruby's search path and
# loads TestUp 2.
$LOAD_PATH << "C:/Users/YourUserName/Documents/testup-2/src"
require "testup.rb"
```

Credits
-------

Thanks to Mark James for making his excellent icon set "Silk" available. Portions of the set is used in this project. Some file names has been renamed and some icons where mixed to create new status indicators for test result.
http://www.famfamfam.com/lab/icons/silk/

License
-------

The MIT License (MIT)

See the LICENSE file for details.
