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

Optionally you can download a RBZ from the [Releases tab on GitHub](https://github.com/SketchUp/testup-2/releases). Beware that this might not be
always up to date. Setting up from git is recommended in order to easily keep
up to date.

Setup for SketchUp Internal Development
---------------------------------------

Follow the same steps as for "Setup for Contributing".

In order to load tests from our Perforce clients the paths where our tests are
needs to be updated. This is done from the Preference dialog found under the
TestUp dialog.

Click the gear symbol and you should see a list of paths. By default these will
be pointing to the git repository's copy of our tests.

To simplify switching between clients a "P4 Clients" button should appear if
you have Perforce set up on your system. Use this button to get a list of
clients on your machine. Typically you want to use the tests from trunk. Pick a
client and then Save - your paths will then update. Restart SketchUp after
saving your changes to ensure you have a clean configuration.

Credits
-------

Thanks to Mark James for making his excellent icon set "Silk" available. Portions of the set is used in this project. Some file names has been renamed and some icons where mixed to create new status indicators for test result.
http://www.famfamfam.com/lab/icons/silk/

License
-------

The MIT License (MIT)

See the LICENSE file for details.
