module FinModeling
  class ReformulatedBalanceSheet

    def initialize(assets_summary, liabs_and_equity_summary)
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
      cs.rows = [ { :key => "OA", :val =>  @oa.total },
                  { :key => "OL", :val => -@ol.total } ]
      return cs
    end

    def net_financial_assets
      cs = FinModeling::CalculationSummary.new
      cs.title = "Net Financial Assets"
      cs.rows = [ { :key => "FA", :val =>  @fa.total },
                  { :key => "FL", :val => -@fl.total } ]
      return cs
    end

    def common_shareholders_equity
      cs = FinModeling::CalculationSummary.new
      cs.title = "Common Shareholders' Equity"
      cs.rows = [ { :key => "NOA", :val =>  net_operating_assets.total },
                  { :key => "NFA", :val =>  net_financial_assets.total } ]
      return cs
    end

    def composition_ratio
      net_operating_assets.total / net_financial_assets.total
    end

    def noa_growth(prev)
      (net_operating_assets.total - prev.net_operating_assets.total) / prev.net_operating_assets.total
    end

    def cse_growth(prev)
      (common_shareholders_equity.total - prev.common_shareholders_equity.total) / prev.common_shareholders_equity.total
    end

  end
end
