module FinModeling
  class BalanceSheetCalculation < CompanyFilingCalculation
    def assets
      calc = @calculation.arcs.find{ |x| x.label.downcase.gsub(/[^a-z ]/, '') =~ /(^total *|^)assets$/ }
      return CompanyFilingCalculation.new(@taxonomy, calc)
    end
  
    def liabs_and_equity
      calc = @calculation.arcs.find{ |x| x.label.downcase.gsub(/[^a-z ]/, '') =~ /(^total *|^)liabilities.*and.*equity/ }
      return CompanyFilingCalculation.new(@taxonomy, calc)
    end
  end
end
