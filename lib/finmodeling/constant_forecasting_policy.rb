module FinModeling
  class ConstantForecastingPolicy  # FIXME: better name would now be LinearForecastingPolicy
    def initialize(args)
      @vals = args
    end

    def revenue_on(date)
      @vals[:revenue_estimator].estimate_on(date)
    end

    def sales_pm_on(date)
      @vals[:sales_pm_estimator].estimate_on(date)
    end
  
    def fi_over_nfa_on(date)
      @vals[:fi_over_nfa_estimator].estimate_on(date)
    end
  
    def sales_over_noa_on(date)
      @vals[:sales_over_noa_estimator].estimate_on(date)
    end
  end
end
