module FinModeling
  class ForecastedReformulatedBalanceSheet < ReformulatedBalanceSheet
    def initialize(period, noa, nfa, cse)
      @period = period
      @noa = noa
      @nfa = nfa
      @cse = cse

      @minority_interest = FinModeling::CalculationSummary.new
    end

    def operating_assets
      nil
    end

    def financial_assets
      nil
    end

    def operating_liabilities
      nil
    end

    def financial_liabilities
      nil
    end

    def net_operating_assets
      cs = FinModeling::CalculationSummary.new
      cs.title = "Net Operational Assets"
      cs.rows = [ CalculationRow.new( :key => "NOA", :vals => [@noa] ) ]
      return cs
    end

    def net_financial_assets
      cs = FinModeling::CalculationSummary.new
      cs.title = "Net Financial Assets"
      cs.rows = [ CalculationRow.new( :key => "NFA", :vals => [@nfa] ) ]
      return cs
    end

    def common_shareholders_equity
      cs = FinModeling::CalculationSummary.new
      cs.title = "Common Shareholders' Equity"
      cs.rows = [ CalculationRow.new( :key => "CSE", :vals => [@cse] ) ]
      return cs
    end
 
    def analysis(prev)
      analysis = super(prev)
      analysis.header_row.vals[0] += "E" # for estimated
      return analysis
    end
  end
end
