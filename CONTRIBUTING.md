# CONTRIBUTING

1. Fork it
2. Create your feature branch (`git checkout -b my_new_feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my_new_feature`)
5. Create a new Pull Request

If you are a project member please follow the same process (minus the forking). For significant changes please wait for another developer to review and merge them, whereas small contributions/fixes can be merged without review.

You may want to look into the [grb](http://github.com/jinzhu/grb) gem for easier handling of remote branches.

## Building

`gem build turn.gemspec`

## Solo and Cross Runners

An important aspect of Turn's design that needs be kept in mind, is the way
_solo_ and _cross_ testing features are implemented. This is some really
neat code actually (IMO), but it might be difficult to grasp with out some
explanation. What turn does when using the `--solo` or `--cross` options,
is <i>shell out to itself</i> using the YAML reporter. It does this repeatedly
for each test, or each pair of tests, respectively, and then collates all the
resulting YAML reports into a single report, which it then feeds back into the
selected reporter.
