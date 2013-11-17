# CONTRIBUTING

1. Fork it
2. Create your feature branch (`git checkout -b my_new_feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my_new_feature`)
5. Create a new Pull Request

If you are a project member please follow the same process (minus the forking). For significant changes please wait for another developer to review and merge them, whereas small contributions/fixes can be merged without review. The recommended naming scheme for feature branches is 'feature\_name\_$1\_`date +"%Y%m%d"`'.

You may want to look into the [grb](http://github.com/jinzhu/grb) gem for easier handling of remote branches.


## Building

NOTE: The process described here will change sooner than later.

Turn uses the Indexer and Mast gems to simplify project building.

The Indexer gem defines a strict structure for project metadata. Use the `index`
command to build the `.index` file from the editable `Index.rb` source.
The `.gemspec` file is written to get the information it needs from the `.index`
file. To build a gem simply use `gem build .gemspec`.

The `mast` command is used to keep an up-to-date `Manifest.txt` file. The gemspec
uses this file to determine which files to include in the gem. Just use
`mast -u` to update it. The top line in the Manifest.txt file determines it's
contents.


## Solo and Cross Runners

An important aspect of Turn's design that needs be kept in mind, is the way
_solo_ and _cross_ testing features are implemented. This is some really
neat code actually (IMO), but it might be difficult to grasp with out some
explanation. What turn does when using the `--solo` or `--cross` options,
is <i>shell out to itself</i> using the YAML reporter. It does this repeatedly
for each test, or each pair of tests, respectively, and then collates all the
resulting YAML reports into a single report, which it then feeds back into the
selected reporter.
