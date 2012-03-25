module FinModeling
  class ConstantForecastingPolicy 
    def initialize(args)
      @vals = args
    end

    def revenue_growth
      @vals[:revenue_growth]
    end
  
    def sales_pm
      @vals[:sales_pm]
    end
  
    def fi_over_nfa
      @vals[:fi_over_nfa]
    end
  
    def sales_over_noa
      @vals[:sales_over_noa]
    end
  end
end
