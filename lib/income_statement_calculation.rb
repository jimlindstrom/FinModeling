module FinModeling
  class IncomeStatementCalculation < CompanyFilingCalculation

    def net_income_calculation
      if @ni.nil?
        friendly_goal = "net income"
        label_regexes = [ /^net income/,
                          /^net loss income/ ]
        id_regexes    = [ /^us-gaap_NetIncomeLoss_.*/ ]
        calc = find_and_verify_calculation_arc(friendly_goal, label_regexes, id_regexes)
        @ni = CompanyFilingCalculation.new(@taxonomy, calc)
      end
      return @ni
    end

    def is_valid?
      has_revenue_item = false
      has_tax_item     = false
      net_income_calculation.leaf_items.each do |leaf|
        if !has_revenue_item and leaf.name.downcase.matches_regexes?([/revenue/, /sales/])
          has_revenue_item = true
        end
        if !has_tax_item and leaf.name.downcase.matches_regexes?([/tax/])
          has_tax_item     = true
        end
      end

      puts "income statement's net income calculation lacks tax item" if !has_tax_item 
      puts "income statement's net income calculation lacks sales/revenue item" if !has_revenue_item 
      return (has_revenue_item and has_tax_item)
    end
  
  end
end
