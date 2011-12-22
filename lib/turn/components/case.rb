module Turn

  #
  class TestCase
    include Enumerable

    # Name of test case.
    attr_accessor :name

    # Test methods.
    attr_accessor :tests

    # Some runners marshal tests per file.
    attr_accessor :files

    #attr_accessor :count_passes
    #attr_accessor :count_failures
    #attr_accessor :count_errors
    #attr_accessor :count_tests

    # This can't be calculated, so it must be
    # assigned by the runner.
    attr_accessor :count_assertions

    # Holds dump of test output (optional depending on runner).
    attr_writer :message

    # Command used to run test (optional depending on runner).
    #attr_accessor :command

    #
    def initialize(name, *files)
      @name  = name
      @files = (files.empty? ? [name] : files)
      @tests = []

      @message = nil
      @count_assertions = 0

      #@count_tests      = 0
      #@count_failures   = 0
      #@count_errors     = 0

      #@command = command
    end

    def new_test(name)
      c = TestMethod.new(name)
      @tests << c
      c
    end

    # Whne used by a per-file runner.
    #alias_method :file, :name

    # Were there any errors?
    def error?
      count_errors != 0
    end

    # Were there any failures?
    def fail?
      count_failures != 0
    end

    # Did all tests/assertion pass?
    def pass?
      not(fail? or error?)
    end

    def count_tests
      tests.size
    end

    alias_method :size, :count_tests

    def count_failures
      sum = 0; tests.each{ |t| sum += 1 if t.fail? }; sum
    end

    def count_errors
      sum = 0; tests.each{ |t| sum += 1 if t.error? }; sum
    end

    def count_passes
      sum = 0; tests.each{ |t| sum += 1 if t.pass? }; sum
    end

    #
    def counts
      return count_tests, count_assertions, count_failures, count_errors
    end

    def message
      tests.collect{ |t| t.message }.join("\n")
    end

    def each(&block)
      tests.each(&block)
    end
  end

end

