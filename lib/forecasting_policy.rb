module FinModeling
  class ForecastingPolicy
    # this class shouldn't be used. It's just some generic constants that can be redefined
    def revenue_growth
      0.04
    end
  
    def sales_pm
      0.20
    end
  
    def fi_over_nfa
      0.01
    end
  
    def sales_over_noa
      2.00
    end
  end
end
