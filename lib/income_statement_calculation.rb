module FinModeling
  class IncomeStatementCalculation < CompanyFilingCalculation

    def operating_expenses
      calc = @calculation.arcs.find{ |x| (x.label.downcase.gsub(/[^a-z ]/, '') =~ /(^|^total )operating expenses/) or
                                         (x.label.downcase.gsub(/[^a-z ]/, '') =~ /costs and expenses/) }
      if calc.nil?
        raise RuntimeError.new("Couldn't find operating expenses in: " + @calculation.arcs.map{ |x| "\"#{x.label}\"" }.join("; "))
      end
      if !(calc.item_id =~ /^us-gaap_CostsAndExpenses_\d+/)
        puts "Warning: operating expenses id is not recognized: #{calc.item_id}"
      end
      return CompanyFilingCalculation.new(@taxonomy, calc)
    end

    def operating_income
      calc = @calculation.arcs.find{ |x| x.label.downcase.gsub(/[^a-z ]/, '') =~ /^operating income/ }
      if calc.nil?
        raise RuntimeError.new("Couldn't find operating income in: " + @calculation.arcs.map{ |x| "\"#{x.label}\"" }.join("; "))
      end
      if !(calc.item_id =~ /^us-gaap_OperatingIncomeLoss_\d+/)
        puts "Warning: operating income id is not recognized: #{calc.item_id}"
      end
      return CompanyFilingCalculation.new(@taxonomy, calc)
    end

    def net_income
      calc = @calculation.arcs.find{ |x| x.label.downcase.gsub(/[^a-z ]/, '') =~ /^net income/ }
      if calc.nil?
        raise RuntimeError.new("Couldn't find net income in: " + @calculation.arcs.map{ |x| "\"#{x.label}\"" }.join("; "))
      end
      if !(calc.item_id =~ /^us-gaap_NetIncomeLoss_\d+/)
        puts "Warning: net income id is not recognized: #{calc.item_id}"
      end
      return CompanyFilingCalculation.new(@taxonomy, calc)
    end
  
  end
end
