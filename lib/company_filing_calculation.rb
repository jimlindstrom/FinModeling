module FinModeling
  class CompanyFilingCalculation
    def initialize(taxonomy, calculation)
      @taxonomy = taxonomy
      @calculation = calculation
    end
  
    def label
      @calculation.label
    end
  end
end
