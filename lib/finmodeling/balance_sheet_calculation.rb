module FinModeling
  class BalanceSheetCalculation < CompanyFilingCalculation

    ASSETS_GOAL   = "assets"
    ASSETS_LABELS = [ /(^total *|^consolidated *|^)assets$/,
                      /^assets total$/ ]
    ASSETS_IDS    = [ /^(|Locator_|loc_)(|us-gaap_)Assets[_a-z0-9]+/ ]
    def assets_calculation
      @assets ||= AssetsCalculation.new(find_calculation_arc(ASSETS_GOAL, ASSETS_LABELS, ASSETS_IDS))
    end
  
    LIABS_AND_EQ_GOAL   = "liabilities and equity"
    LIABS_AND_EQ_LABELS = [ /(^total *|^)liabilities.*and.*equity/ ]
    LIABS_AND_EQ_IDS    = [ /.*/ ] # FIXME: no checking...
    def liabs_and_equity_calculation
       @liabs_and_eq ||= LiabsAndEquityCalculation.new(find_calculation_arc(LIABS_AND_EQ_GOAL, LIABS_AND_EQ_LABELS, LIABS_AND_EQ_IDS))
    end

    def is_valid?
      puts "balance sheet's assets calculation lacks cash item"                   if !assets_calculation.has_cash_item 
      puts "balance sheet's liabilities and equity calculation lacks equity item" if !liabs_and_equity_calculation.has_equity_item 
      puts "balance sheet's isn't balanced"                                       if !is_balanced
      return (assets_calculation.has_cash_item && 
              liabs_and_equity_calculation.has_equity_item && 
              is_balanced)
    end

    def reformulated(period)
      return ReformulatedBalanceSheet.new(period, 
                                          assets_calculation          .summary(:period=>period), 
                                          liabs_and_equity_calculation.summary(:period=>period))
    end

    def write_constructor(file, item_name)
      item_calc_name = item_name + "_calc"
      @calculation.write_constructor(file, item_calc_name)
      file.puts "#{item_name} = FinModeling::BalanceSheetCalculation.new(#{item_calc_name})"
    end

    def is_balanced
      left  = assets_calculation          .leaf_items_sum(:period => periods.last, :mapping => assets_calculation.mapping)
      right = liabs_and_equity_calculation.leaf_items_sum(:period => periods.last, :mapping => liabs_and_equity_calculation.mapping)

      is_bal = (left - right) < ((0.5*(left + right))/1000.0)
      if !is_bal
        puts "balance sheet last period: #{periods.last.inspect}"
        puts "balance sheet left  side: #{left}"
        puts "balance sheet right side: #{right}"
        puts "left:"
        assets_calculation.summary(:period => periods.last).print
        puts "right:"
        liabs_and_equity_calculation.summary(:period => periods.last).print
      end
      is_bal
    end

  end
end
