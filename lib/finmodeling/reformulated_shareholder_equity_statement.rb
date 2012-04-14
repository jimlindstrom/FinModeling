module FinModeling
  class ReformulatedShareholderEquityStatement
    attr_accessor :period

    def initialize(period, equity_change_summary)
      @period                = period

      @share_issue   = equity_change_summary.filter_by_type(:share_issue  )
      @minority_int  = equity_change_summary.filter_by_type(:minority_int )
      @share_repurch = equity_change_summary.filter_by_type(:share_repurch)
      @common_div    = equity_change_summary.filter_by_type(:common_div   )
      @net_income    = equity_change_summary.filter_by_type(:net_income   )
      @oci           = equity_change_summary.filter_by_type(:oci          )
      @preferred_div = equity_change_summary.filter_by_type(:preferred_div)
    end

    def transactions_with_shareholders
      cs = FinModeling::CalculationSummary.new
      cs.title = "Transactions with Shareholders"
      cs.rows = [ CalculationRow.new(:key => "Share Issues",      :vals => [@share_issue  .total] ),
                  CalculationRow.new(:key => "Minority Interest", :vals => [@minority_int .total] ),
                  CalculationRow.new(:key => "Share Repurchases", :vals => [@share_repurch.total] ),
                  CalculationRow.new(:key => "Common Dividends",  :vals => [@common_div   .total] ) ]
      return cs
    end

    def comprehensive_income
      cs = FinModeling::CalculationSummary.new
      cs.title = "comprehensive_income"
      cs.rows = [ CalculationRow.new(:key => "Net Income",                 :vals => [@net_income   .total] ),
                  CalculationRow.new(:key => "Other Comprehensive Income", :vals => [@oci          .total] ),
                  CalculationRow.new(:key => "Preferred Dividends",        :vals => [@preferred_div.total] ) ]
      return cs
    end
 
    def analysis
      analysis = CalculationSummary.new
  
      analysis.title = ""
      analysis.header_row = CalculationHeader.new(:key => "", :vals => [@period.value["end_date"].to_s])
  
      analysis.rows = []
      analysis.rows << CalculationRow.new(:key => "Tx w Shareholders ($MM)", :vals => [transactions_with_shareholders.total.to_nearest_million])
      analysis.rows << CalculationRow.new(:key => "CI ($MM)",                :vals => [comprehensive_income.total.to_nearest_million])
 
      return analysis
    end

  end
end
