module FinModeling
  class BalanceSheetCalculation < CompanyFilingCalculation
    def assets
      calc = @calculation.arcs.find{ |x| x.label.downcase.gsub(/[^a-z ]/, '') =~ /(^total *|^)assets$/ }
      if calc.nil?
        raise RuntimeError.new("Couldn't find assets in: " + @calculation.arcs.map{ |x| "\"#{x.label}\"" }.join("; "))
      end
      if !(calc.item_id =~ /^us-gaap_Assets_\d+/) and !(calc.item_id =~ /^Assets_\d+/)
        put "Warning: assets id is not recognized: #{calc.item_id}"
      end
      return CompanyFilingCalculation.new(@taxonomy, calc)
    end
  
    def liabs_and_equity
      calc = @calculation.arcs.find{ |x| x.label.downcase.gsub(/[^a-z ]/, '') =~ /(^total *|^)liabilities.*and.*equity/ }
      if calc.nil?
        raise RuntimeError.new("Couldn't find liabs and equity in: " + @calculation.arcs.map{ |x| "\"#{x.label}\"" }.join("; "))
      end
      return CompanyFilingCalculation.new(@taxonomy, calc)
    end
  end
end
