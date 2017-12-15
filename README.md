TestUp 2 for SketchUp
=====================

TestUp is a wrapper on top of the [minitest](https://github.com/seattlerb/minitest) gem. It allow SketchUp Extension developers to write `minitest` tests that runs within SketchUp.

![](docs/overview.png)

Requirements
------------

1. SketchUp 2014 or newer.

Setup for Extension Developers
------------------------------

Install TestUp from `git` (See Setup for Contributing) or download RBZ from the [Releases tab on GitHub](https://github.com/SketchUp/testup-2/releases). (The Releases downloads might be behind.)

Check out the [wiki](https://github.com/SketchUp/testup-2/wiki) for details on creating tests. Make sure to also refer to [minitest documentation](http://docs.seattlerb.org/minitest/).

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

Logging and Re-running
----------------------

TestUp will log the details of a test-run. These can be found by using the menu
`Extensions > TestUp > Open Log Folder`.

In there you will find `.log` and `.run` files.

The `.log` files are for human reading, containing information about the
environment and what tests ran.

The `.run` files are JSON files which can be used to re-play a test-run. From
the TestUp main dialog, click the `Re-run...` button and select the `.run` file
you are interested in. This will re-run the exact same tests with the same seed
so they are also run in the same order.

If you need to re-run a particular run several times you can use
`Extensions > TestUp > Saved Runs > Add Run`. Then you can pick it from the
drop-down after choosing `Extensions > TestUp > Saved Runs > Set Re-play Run`.

Credits
-------

Thanks to Mark James for making his excellent icon set "Silk" available. Portions of the set is used in this project. Some file names has been renamed and some icons where mixed to create new status indicators for test result.
http://www.famfamfam.com/lab/icons/silk/

License
-------

The MIT License (MIT)

See the LICENSE file for details.
