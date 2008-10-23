module Turn
  require 'turn/runners/isorunner'

  # = Cross Runner
  #
  # Cross Runner runs test in pairs.
  #
  # TODO: This needs work in the test_loop_runner.
  #       It needs to show the files being cross tested.
  class CrossRunner < IsoRunner

    #
    def start
      suite = TestSuite.new

      files = @controller.files
      viles = @controller.files # TODO: viles this selectable

      #files = files.select{ |f| File.extname(f) == '.rb' and File.file?(f) }
      #viles = viles.select{ |f| File.extname(f) == '.rb' and File.file?(f) }

      max = (files+viles).collect{ |f| f.size }.max

      pairs = files.inject([]){ |m, f| viles.collect{ |g| m << [f,g] }; m }
      #pairs = pairs.reject{ |f,v| f == v }

      testruns = pairs.collect do |file, versus|
        name = "%-#{max}s %-#{max}s" % [file, versus]
        suite.new_case(name, file, versus)
      end

      test_loop_runner(suite)
    end

  end

end

