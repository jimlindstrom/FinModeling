module FinModeling
  class GenericForecastingPolicy 
    def revenue_on(date)
      0.04
    end
  
    def sales_pm_on(date)
      0.20
    end
  
    def fi_over_nfa_on(date)
      0.01
    end
  
    def sales_over_noa_on(date)
      2.00
    end
  end
end
