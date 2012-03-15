module FinModeling
  class CashFlowStatementCalculation < CompanyFilingCalculation

    def cash_change_calculation
      if @cash_change.nil?
        friendly_goal = "cash change"
        label_regexes = [ /^cash and cash equivalents period increase decrease/,
                          /^net increase decrease in cash and cash equivalents/ ]
        id_regexes    = [ /^us-gaap_CashAndCashEquivalentsPeriodIncreaseDecrease_\d+/,
                          /^CashAndCashEquivalentsPeriodIncreaseDecrease\d+/ ]
  
        calc = find_and_verify_calculation_arc(friendly_goal, label_regexes, id_regexes)
        @cash_change = CashChangeCalculation.new(calc)
      end
      return @cash_change
    end
  
#    def liabs_and_equity_calculation
#       if @liabs_and_equity.nil?
#        friendly_goal = "liabilities and equity"
#        label_regexes = [ /(^total *|^)liabilities.*and.*equity/ ]
#        id_regexes    = [ /.*/ ] # no checking...
#  
#        calc = find_and_verify_calculation_arc(friendly_goal, label_regexes, id_regexes)
#        @liabs_and_equity = LiabsAndEquityCalculation.new(calc)
#      end
#      return @liabs_and_equity
#    end
#
#    def is_valid?
#      has_cash_item = false
#      assets_calculation.leaf_items.each do |leaf|
#        if !has_cash_item and leaf.name.downcase.matches_regexes?([/cash/])
#          has_cash_item = true
#        end
#      end
#
#      has_equity_item = false
#      liabs_and_equity_calculation.leaf_items.each do |leaf|
#        if !has_equity_item and leaf.name.downcase.matches_regexes?([/equity/, /stock/])
#          has_equity_item = true
#        end
#      end
#
#      left = assets_calculation.leaf_items_sum(periods.last)
#      right = liabs_and_equity_calculation.leaf_items_sum(periods.last)
#      allowed_error = 1.0
#      is_balanced = (left + right) < allowed_error
#
#      puts "balance sheet's assets calculation lacks cash item" if !has_cash_item 
#      puts "balance sheet's liabilities and equity calculation lacks equity item" if !has_equity_item 
#      return (has_cash_item and has_equity_item and is_balanced)
#    end
#
#    def reformulated(period)
#      return ReformulatedCashFlowStatement.new(period, assets_calculation.summary(period), liabs_and_equity_calculation.summary(period))
#    end
#
#    def write_constructor(file, item_name)
#      item_calc_name = item_name + "_calc"
#      @calculation.write_constructor(file, item_calc_name)
#      file.puts "#{item_name} = FinModeling::CashFlowStatementCalculation.new(#{item_calc_name})"
#    end

  end
end
