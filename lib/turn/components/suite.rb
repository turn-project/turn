module Turn

  #
  class TestSuite

    include Enumerable

    attr_accessor :name
    attr_accessor :cases
    attr_accessor :seed

    # This one can be set manually since it
    # is not calculatable (beyond the case level).
    attr_writer :count_assertions

    #
    def initialize(name=nil)
      @name  = name
      @cases = []
      @size  = nil
      @seed  = nil

      #@count_tests      = nil
      #@count_assertions = nil
      #@count_failures   = nil
      #@count_errors     = nil
      #@count_passes     = nil
    end

    #
    def new_case(name, *files)
      c = TestCase.new(name, *files)
      @cases << c
      c
    end

    def count_tests
      #@count_tests ||= (
        sum = 0; each{ |c| sum += c.count_tests }; sum
      #)
    end

    def count_assertions
      #@count_assertions ||= (
        sum = 0; each{ |c| sum += c.count_assertions }; sum
      #)
    end

    def count_failures
      #@count_failures ||= (
        sum = 0; each{ |c| sum += c.count_failures }; sum
      #)
    end

    def count_errors
      #@count_errors ||= (
        sum = 0; each{ |c| sum += c.count_errors }; sum
      #)
    end

    def count_passes
      #@count_passes ||= (
        sum = 0; each{ |c| sum += c.count_passes }; sum
      #)
    end

    def count_skips
      sum = 0; each{ |c| sum += c.count_skips }; sum
    end

    # Convenience methods --this is what is typcially wanted.
    def counts
      return count_tests, count_assertions, count_failures, count_errors ,count_skips
    end

    def each(&block)
      @cases.each(&block)
    end

    def size
      @size ||= @cases.size
    end

    # Why the size would ever have to overridden... well who can say.
    def size=(number)
      @size = number.to_i
    end

    def passed?
      (count_failures == 0 && count_errors == 0)
    end
  end

end