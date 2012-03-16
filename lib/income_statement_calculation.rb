module FinModeling
  class IncomeStatementCalculation < CompanyFilingCalculation

    def net_income_calculation
      if @ni.nil?
        friendly_goal = "net income"
        label_regexes = [ /^net income/,
                          /^net loss income/,
                          /^allocation.*of.*undistributed.*earnings/ ]
        id_regexes    = [ /^us-gaap_NetIncomeLoss_.*/,
                          /^ProfitLoss_\d+/ ]
        calc = find_and_verify_calculation_arc(friendly_goal, label_regexes, id_regexes)
        @ni = NetIncomeCalculation.new(calc)
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

    def reformulated(period)
      return ReformulatedIncomeStatement.new(period, 
                                             net_income_calculation.summary(:period=>period))
    end
 
    def write_constructor(file, item_name)
      item_calc_name = item_name + "_calc"
      @calculation.write_constructor(file, item_calc_name)
      file.puts "#{item_name} = FinModeling::IncomeStatementCalculation.new(#{item_calc_name})"
    end

  end
end
