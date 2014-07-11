# TURN - MiniTest Reporters [![Build status](https://api.travis-ci.org/turn-project/turn.png)](https://travis-ci.org/turn-project/turn)
    by Tim Pease & Trans
    http://rubygems.org/gems/turn

## IMPORTANT

**TURN is no longer being maintained!**

Ruby's built-in test framework has changed so frequently (and rather poorly)
over the last few years that it has been a relative nightmare to try keep Turn 
working. From the deprecation of Test::Unit and the switch to MiniTest and thru
all the many API changes made to MiniTest itself (we're at major version 5 now!),
it is simply not conducive to a coder's productivity to have to rewrite a program
every year while explaining to gracious bug reporters that it's broken
because the underlying API has changed yet again.

The most recent major change finally added something of a real reporter API. 
That's a good thing! Although it should have been there from day one. Yet
the new version also removed the runner API. That's means Turn would have
revert back to old subclassing and monkey patching tricks in order support
certain features such as the solo and cross runners.

As any programmer can well understand, I have no interest in playing these
musical chairs any longer. I have endeavored to provide preliminary support
for Minitest v5+, which is now in the master branch. For the most part,
the reporter part, it is working. But there are plenty of loose ends that
have to be tied up if everything is to work as it should.

If someone else would like to take up the mantle of this project please 
have at it. I'm available to answer any questions. Until then, consider
this entire project *deprecated*.

Sincerely,
**trans**
</b>


## DESCRIPTION

TURN is a new way to view test results. With longer running tests, it
can be very frustrating to see a failure (....F...) and then have to wait till
all the tests finish before you can see what the exact failure was. TURN
displays each test on a separate line with failures being displayed
immediately instead of at the end of the tests.

If you have the 'ansi' gem installed, then TURN output will be displayed in
wonderful technicolor (but only if your terminal supports ANSI color codes).
Well, the only colors are green and red, but that is still color.


## FEATURES

General usage provides better test output. Here is some sample output:


    TestMyClass
        test_alt                                                            PASS
        test_alt_eq                                                         PASS
        test_bad                                                            FAIL
            ./test/test_my_class.rb:64:in `test_bad'
            <false> is not true.
        test_foo                                                            PASS
        test_foo_eq                                                         PASS
    TestYourClass
        test_method_a                                                       PASS
        test_method_b                                                       PASS
        test_method_c                                                       PASS
    ============================================================================
      pass: 7,  fail: 1,  error: 0
      total: 15 tests with 42 assertions in 0.018 seconds
    ============================================================================


Turn also provides solo and cross test modes when run from the *turn* commandline
application.

## INSTRUCTION

Turn can be used from the command-line or via require. The command-line tool
offers additional options for how one runs tests.

### Command Line

You can use the *turn* executable in place of the *ruby* interpreter.

    $ turn -Ilib test/test_all.rb

This will invoke the ruby interpreter and automatically require the turn
formatting library. All command line arguments are passed "as is" to the
ruby interpreter.

To use the solo runner.

    $ turn --solo -Ilib test/

This will run all tests in the test/ directory in a separate process.
Likewise for the cross runner.

    $ turn --cross -Ilib test/

This will run every pairing of tests in a separate process.

### Via Require

Simply require the TURN package from within your test suite.

    $ require 'turn/autorun'

This will configure MiniTest to use TURN formatting for displaying test
results. A better line to use, though, is the following:

    begin; require 'turn/autorun'; rescue LoadError; end

When you distribute your code, the test suite can be run without requiring
the end user to install the TURN package.

For a Rails application, put the require line into the 'test/test_helper.rb'
script. Now your Rails tests will use TURN formatting.

<b>Note:</b> This changed in version 0.9. It used to be just `require 'turn'`,
but because of how `bundle exec` works, it was better to require a subdirectory
file.

### Configuration

You can use `Turn.config` to adjust turn configuration.

Options are following:

    tests           List of file names or glob patterns of tests to run. Default: ["test/**/{test,}*{,test}.rb"]
    exclude         List of file names or globs to exclude from tests list. Default: []
    pattern         Regexp pattern that all test names must match to be eligible to run. Default: /.*/ (all)
    matchcase       Regexp pattern that all test cases must match to be eligible to run. Default: nil (all)
    loadpath        Add these folders to the $LOAD_PATH. Default: ['lib']
    requires        Libs to require when running tests. Default: []
    format          Reporter type (:pretty, :dot, :cue, :marshal, :outline, :progress). Default: :pretty
    live            Test against live install (i.e. Don't use loadpath option). Default: false
    verbose         Verbose output? Default: false
    trace           Number of backtrace lines to display. Default: set from ENV or nil (all)
    natural         Use natural language case names.  Default: false
    ansi            Force colorized output (requires 'ansi' gem). Default: set from ENV or nil (auto)

To set option just call the desired method:

    Turn.config.format = :progress

Also, you can use following environment variables to adjust settings:

    backtrace       Number of backtrace lines to display. Default: set from ENV or nil
    ansi            Force colorize output (requires 'ansi' gem).

Finally, you can include your own custom Reporter type (aka format). Turn will search for reporters in the `.turn/reporters/`
directory of your local project and then in your user home directory. So for example, if you specified the following:

    Turn.config.format = :cool

Then Turn will look first for `./.turn/reporters/cool_reporter.rb`, then `~/.turn/reporters/cool_reporter.rb`.

See source code for examples of how to write your own reporters.


## REQUIREMENTS

* ansi 1.1+ (for colorized output and progress bar output mode)

## INSTALLATION

Follow the usual procedure:

    $ gem install turn

## TODO

* Support MiniTest v5.0
* General code cleanup

# CONTRIBUTING

1. Fork it
2. Create your feature branch (`git checkout -b my_new_feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my_new_feature`)
5. Create a new Pull Request

If you are a project member please follow the same process (minus the forking). For significant changes please wait for another developer to review and merge them, whereas small contributions/fixes can be merged without review.

## Building

To build the gem simply run:

    gem build .gemspec

## Solo and Cross Runners

An important aspect of Turn's design that needs be kept in mind, is the way
_solo_ and _cross_ testing features are implemented. This is some really
neat code actually (IMO), but it might be difficult to grasp with out some
explanation. What turn does when using the `--solo` or `--cross` options,
is <i>shell out to itself</i> using the YAML reporter. It does this repeatedly
for each test, or each pair of tests, respectively, and then collates all the
resulting YAML reports into a single report, which it then feeds back into the
selected reporter.

## LICENSE

MIT License

Copyright (c) 2006 Tim Pease
Copyright (c) 2009 Thomas Sawyer

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
