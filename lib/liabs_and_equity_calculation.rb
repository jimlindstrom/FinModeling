module FinModeling
  class LiabsAndEquityCalculation < CompanyFilingCalculation

    def summary(period)
      super(period, type_to_flip="debit", flip_total=true)
    end
 
  end
end
