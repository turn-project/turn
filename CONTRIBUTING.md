# CONTRIBUTING

## Building

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
