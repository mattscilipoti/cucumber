module Cucumber
  class Runtime
    
    class Results
      def step_visited(step) #:nodoc:
        steps << step unless steps.index(step)
      end
      
      def scenario_visited(scenario) #:nodoc:
        scenarios << scenario unless scenarios.index(scenario)
      end
      
      def steps(status = nil) #:nodoc:
        @steps ||= []
        if(status)
          @steps.select{|step| step.status == status}
        else
          @steps
        end
      end
      
      def scenarios(status = nil) #:nodoc:
        @scenarios ||= []
        if(status)
          @scenarios.select{|scenario| scenario.status == status}
        else
          @scenarios
        end
      end
    end
    
  end
end