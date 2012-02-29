module FinModeling
  class AssetsCalculation < CompanyFilingCalculation

    def summary(period)
      super(period, type_to_flip="credit", flip_total=false)
    end
 
  end
end
