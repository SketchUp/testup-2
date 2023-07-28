# TestUp 2 for SketchUp

TestUp is a wrapper on top of the [minitest](https://github.com/seattlerb/minitest) gem. It allow SketchUp Extension developers to write `minitest` tests that runs within SketchUp.

![](docs/overview.png)

## Requirements

1. SketchUp 2014 or newer.

## Setup for Extension Developers

Easy: Download RBZ from the [Releases tab on GitHub](https://github.com/SketchUp/testup-2/releases).

Latest: Install TestUp from `git` source (See Setup for Contributing). Requires [Node](https://nodejs.org) to build webdialog content before 2.3+ versions can be used.

Check out the [wiki](https://github.com/SketchUp/testup-2/wiki) for details on creating tests. Make sure to also refer to [minitest documentation](http://docs.seattlerb.org/minitest/).

Examples of extension projects implementing TestUp tests:
* https://bitbucket.org/thomthom/quadface-tools/src
* https://github.com/thomthom/shadow-texture/tree/dev-vscode-debug

## Setup for Contributing/Running from Source

TestUp require [NodeJS](https://nodejs.org) to build webdialog resources: https://nodejs.org/en/ (Version 10.4 was used to build TestUp 2.3)

1. Fork the project to your own GitHub account. This is important so that we can do code review on changes done.
_Do **not** push directly to the main repository._

2. Clone your fork to your computer.

3. Open a command line at the project root:
    1. `npm install`
    2. `npm run build`

    You can also use `npm run build -- --watch` to automatically rebuild whenever files changes.

4. Add a helper Ruby file in your Plugins folder:

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

## Setup for SketchUp Internal Development

Follow the same steps as for "Setup for Contributing".

In order to load tests from our source code the paths where our tests are
needs to be updated. This is done from the Preference dialog found under the
TestUp dialog.

Click the gear symbol and you should see a list of paths. By default these will
be pointing to the git repository's copy of our tests.

## Packaging RBZ for Release

To package an RBZ from the content of the `src` directory run:
(This assumes the binary libraries and webdialog resources have been built.)

```
npm run package
```

To build webdialogs and package in a single command:

```
npm run release
```

The RBZ appear in a generated `archive` directory in the project root.

## Logging and Re-running

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

## Running from Terminal

### Running a Full Suite

Windows:
```sh
 "C:\Program Files\SketchUp\SketchUp 2021\SketchUp.exe" -RubyStartupArg "TestUp:CI:Path: C:\Users\Thomas\SourceTree\TestUp2\tests\TestUp UI Tests" > results.json
```

macOS:
```
'/Applications/SketchUp 2021/SketchUp.app/Contents/MacOS/sketchup' -RubyStartupArg 'TestUp:CI:Path: C:/Users/Thomas/SourceTree/TestUp2/tests/TestUp UI Tests' > results.json
```

In the example above TestUp will run a test suite given its path. The ` > results.json` will redirect the STDOUT to a file which will contain the JSON results of the test run.

### Running with Custom Config

```yml
# Config.yml
# Required:
Path: C:\Users\Thomas\SourceTree\TestUp2\tests\TestUp UI Tests

# Optional: (By default, don't include a fixed seed!)
Seed: 123 # The seed number for the random order of execution of the tests

# Optional:
# By default the results will be output to STDOUT. This can be redirected to a
# file.
Output: C:\Users\Thomas\SourceTree\TestUp2\tests\results.json

# Optional:
# Overriding where the .log files from a test run will be saved.
LogPath: C:\Users\Thomas\SourceTree\TestUp2\logs

# Optional:
# Overriding where the .run files from a test run will be saved.
SavedRunsPath: C:\Users\Thomas\SourceTree\TestUp2\logs

# Optional:
# Set to true to prevent SketchUp from closing. Useful for debugging purposes.
# Note that if `Output` is used the results won't be written until SketchUp is
# closed.
KeepOpen: false

# Optional:
# List the set of sets you want to run.
#   Run all tests in test case: TC_TestCaseName#
#   Run specific test: TC_TestCaseName#test_testname
Tests:
- TC_TestSamples#
- TC_TestErrors#test_pass
- TC_TestErrors#test_skip
```

Windows:
```sh
"C:\Program Files\SketchUp\SketchUp 2021\SketchUp.exe" -RubyStartupArg "TestUp:CI:Config: \Full\Path\To\Config.yml"
```

macOS:
```sh
'/Applications/SketchUp 2021/SketchUp.app/Contents/MacOS/sketchup' -RubyStartupArg 'TestUp:CI:Config: /Full/Path/To/Config.yml'
```

### Configuration File Variables

#### `%CONFIG_DIR%`

Expands to the directory where the configuration file is located.

Given a configuration file located at `C:/Users/Thomas/SourceTree/TestUp2/testup-ui-ci.yaml` then `%CONFIG_DIR%` will resolve to `C:/Users/Thomas/SourceTree/TestUp2`.

```yml
# testup-ui-ci.yaml
Path: "%CONFIG_DIR%/tests/TestUp UI Tests"
Output: "%CONFIG_DIR%/tests/ui-tests-results.json"
```

## Troubleshooting

### Minitest

If you should get errors that relate to failing to install Minitest then you
can attempt to install manually from a backup copy in this GitHub repository:

```ruby
# From the SketchUp Ruby Console:
Gem.install('/path/to/repo/testup-2/gems-backup/minitest-5.4.3.gem')
# Then restart SketchUp.
```

## Credits

Thanks to Mark James for making his excellent icon set "Silk" available. Portions of the set is used in this project. Some file names has been renamed and some icons where mixed to create new status indicators for test result.
http://www.famfamfam.com/lab/icons/silk/

## License

The MIT License (MIT)

See the LICENSE file for details.
