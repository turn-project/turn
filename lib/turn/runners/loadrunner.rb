# TODO

    # Load each test independently to ensure there are no
    # require dependency issues. This is actually a bit redundant
    # as test-solo will also cover these results. So we may deprecate
    # this in the future. This does not generate a test log entry.

    def test_load(options={})
      options = test_configuration(options)

      tests    = options['tests']
      loadpath = options['loadpath']
      requires = options['requires']
      live     = options['live']
      exclude  = options['exclude']

      files = Dir.multiglob_r(*tests) - Dir.multiglob_r(*exclude)

      return puts("No tests.") if files.empty?

      max   = files.collect{ |f| f.size }.max
      list  = []

      files.each do |f|
        next unless File.file?(f)
        if r = system("ruby -I#{loadpath.join(':')} #{f} > /dev/null 2>&1")
          puts "%-#{max}s  [PASS]" % [f]  #if verbose?
        else
          puts "%-#{max}s  [FAIL]" % [f]  #if verbose?
          list << f
        end
      end

      puts "  #{list.size} Load Failures"

      if verbose?
        unless list.empty?
          puts "\n-- Load Failures --\n"
          list.each do |f|
            print "* "
            system "ruby -I#{loadpath} #{f} 2>&1"
            #puts
          end
          puts
        end
      end
    end

