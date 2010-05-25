require 'turn/reporter'
require 'yaml'

module Turn

  # = Marshal Reporter
  #
  class MarshalReporter < Reporter

    def finish_suite(suite)    
      $stdout << suite.to_yaml
    end

  end

end

