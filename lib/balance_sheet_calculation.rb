module FinModeling
  class BalanceSheetCalculation < CompanyFilingCalculation

    def assets_calculation
      if @assets.nil?
        friendly_goal = "assets"
        label_regexes = [ /(^total *|^)assets$/,
                          /^assets total$/ ]
        id_regexes    = [ /^us-gaap_Assets_\d+/,
                          /^Assets_\d+/ ]
  
        calc = find_and_verify_calculation_arc(friendly_goal, label_regexes, id_regexes)
        @assets = AssetsCalculation.new(@taxonomy, calc)
      end
      return @assets
    end
  
    def liabs_and_equity_calculation
       if @liabs_and_equity.nil?
        friendly_goal = "liabilities and equity"
        label_regexes = [ /(^total *|^)liabilities.*and.*equity/ ]
        id_regexes    = [ /.*/ ] # no checking...
  
        calc = find_and_verify_calculation_arc(friendly_goal, label_regexes, id_regexes)
        @liabs_and_equity = LiabsAndEquityCalculation.new(@taxonomy, calc)
      end
      return @liabs_and_equity
    end

    def is_valid?
      has_cash_item = false
      assets_calculation.leaf_items.each do |leaf|
        if !has_cash_item and leaf.name.downcase.matches_regexes?([/cash/])
          has_cash_item = true
        end
      end

      has_equity_item = false
      liabs_and_equity_calculation.leaf_items.each do |leaf|
        if !has_equity_item and leaf.name.downcase.matches_regexes?([/equity/, /stock/])
          has_equity_item = true
        end
      end

      left = assets_calculation.leaf_items_sum(periods.last)
      right = liabs_and_equity_calculation.leaf_items_sum(periods.last)
      allowed_error = 1.0
      is_balanced = (left + right) < allowed_error

      puts "balance sheet's assets calculation lacks cash item" if !has_cash_item 
      puts "balance sheet's liabilities and equity calculation lacks equity item" if !has_equity_item 
      return (has_cash_item and has_equity_item and is_balanced)
    end

    def reformulated(period)
      return ReformulatedBalanceSheet.new(assets_calculation.summary(period), liabs_and_equity_calculation.summary(period))
    end

  end
end
