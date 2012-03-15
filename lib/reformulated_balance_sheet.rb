module FinModeling
  class ReformulatedBalanceSheet
    attr_accessor :period

    def initialize(period, assets_summary, liabs_and_equity_summary)
      @period = period
      @oa  = assets_summary.filter_by_type(:oa)
      @fa  = assets_summary.filter_by_type(:fa)
      @ol  = liabs_and_equity_summary.filter_by_type(:ol)
      @fl  = liabs_and_equity_summary.filter_by_type(:fl)
      @cse = liabs_and_equity_summary.filter_by_type(:cse)
    end

    def operating_assets
      @oa
    end

    def financial_assets
      @fa
    end

    def operating_liabilities
      @ol
    end

    def financial_liabilities
      @fl
    end

    def net_operating_assets
      cs = FinModeling::CalculationSummary.new
      cs.title = "Net Operational Assets"
      cs.rows = [ CalculationSummaryRow.new( :key => "OA", :val =>  @oa.total ),
                  CalculationSummaryRow.new( :key => "OL", :val => -@ol.total ) ]
      return cs
    end

    def net_financial_assets
      cs = FinModeling::CalculationSummary.new
      cs.title = "Net Financial Assets"
      cs.rows = [ CalculationSummaryRow.new( :key => "FA", :val =>  @fa.total ),
                  CalculationSummaryRow.new( :key => "FL", :val => -@fl.total ) ]
      return cs
    end

    def common_shareholders_equity
      cs = FinModeling::CalculationSummary.new
      cs.title = "Common Shareholders' Equity"
      cs.rows = [ CalculationSummaryRow.new( :key => "NOA", :val =>  net_operating_assets.total ),
                  CalculationSummaryRow.new( :key => "NFA", :val =>  net_financial_assets.total ) ]
      return cs
    end

    def composition_ratio
      net_operating_assets.total / net_financial_assets.total
    end

    def noa_growth(prev)
      ratio = (net_operating_assets.total - prev.net_operating_assets.total) / prev.net_operating_assets.total
      return annualize_ratio(prev, ratio)
    end

    def cse_growth(prev)
      ratio = (common_shareholders_equity.total - prev.common_shareholders_equity.total) / prev.common_shareholders_equity.total
      return annualize_ratio(prev, ratio)
    end

    private

    def annualize_ratio(prev, ratio)
      from_days = Xbrlware::DateUtil.days_between(prev.period.value, @period.value)
      return Rate.new(ratio).annualize(from_days, to_days=365)
    end

    def deannualize_ratio(prev, ratio)
      to_days = Xbrlware::DateUtil.days_between(prev.period.value,   @period.value)
      return Rate.new(ratio).annualize(from_days=365, to_days)
    end

  end
end
