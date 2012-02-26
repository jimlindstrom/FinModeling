module FinModeling
  class BalanceSheetCalculation < CompanyFilingCalculation
    def assets
      calc = @calculation.arcs.find{ |x| x.label.downcase.gsub(/[^a-z ]/, '') =~ /(^total *|^)assets$/ }
      if !(calc.item_id =~ /^us-gaap_Assets_\d+/) and !(calc.item_id =~ /^Assets_\d+/)
        put "Warning: assets id is not recognized: #{calc.item_id}"
      end
      return CompanyFilingCalculation.new(@taxonomy, calc)
    end
  
    def liabs_and_equity
      calc = @calculation.arcs.find{ |x| x.label.downcase.gsub(/[^a-z ]/, '') =~ /(^total *|^)liabilities.*and.*equity/ }
      return CompanyFilingCalculation.new(@taxonomy, calc)
    end
  end
end
