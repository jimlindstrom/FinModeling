module FinModeling
  class GenericForecastingPolicy 
    def initialize(opts)
      @opts = opts
    end

    def revenue_on(date)
      @opts[:operating_revenues]
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
