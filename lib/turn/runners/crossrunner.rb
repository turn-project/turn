module Turn
  require 'turn/runners/isorunner'

  # = Cross Runner
  #
  # Cross Runner runs test in pairs.
  #
  # TODO: This needs work in the test_loop_runner.
  #       It needs to show the files being cross tested.
  #
  # TODO: Cross runner output needs to be fixed
  class CrossRunner < IsoRunner

    #
    def start
      suite = TestSuite.new

      files = @config.files
      viles = @config.files # TODO: make selectable ?

      #files = files.select{ |f| File.extname(f) == '.rb' and File.file?(f) }
      #viles = viles.select{ |f| File.extname(f) == '.rb' and File.file?(f) }

      pairs = files.inject([]){ |m, f| viles.collect{ |v| m << [f,v] }; m }
      pairs = pairs.reject{ |f,v| f == v }

      max = files.collect{ |f| f.sub(Dir.pwd+'/','').size }.max

      testruns = pairs.collect do |file1, file2|
        name1 = file1.sub(Dir.pwd+'/','')
        name2 = file2.sub(Dir.pwd+'/','')
        name = "%-#{max}s %-#{max}s" % [name1, name2]
        suite.new_case(name, file1, file2)
      end

      test_loop_runner(suite)
    end

  end

end

