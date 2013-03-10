module FinModeling
  class WeightedAvgCostOfCapital
    attr_reader :rate

    def initialize(equity_market_val, debt_market_val, cost_of_equity, after_tax_cost_of_debt)
      @equity_market_val      = equity_market_val 
      @debt_market_val        = debt_market_val
      @cost_of_equity         = cost_of_equity
      @after_tax_cost_of_debt = after_tax_cost_of_debt

      e_weight = @equity_market_val / (@equity_market_val + @debt_market_val)
      d_weight = @debt_market_val   / (@equity_market_val + @debt_market_val)

      @rate = Rate.new((e_weight * @cost_of_equity.value) + (d_weight * @after_tax_cost_of_debt.value))
    end

    def summary
      s = CalculationSummary.new
      s.title = "Cost of Capital"
      s.totals_row_enabled = false

      s.header_row = CalculationHeader.new(:key => "", :vals => [Date.today.to_s])

      s.rows = [ ]

      s.rows << CalculationRow.new(:key => "Market Value of Equity ($MM)", :vals => [@equity_market_val.to_nearest_million])
      s.rows << CalculationRow.new(:key => "Market Value of Debt ($MM)", :vals => [@debt_market_val.to_nearest_million])
      s.rows << CalculationRow.new(:key => "Cost of Equity (%)", :vals => [sprintf("%.2f", 100.0*@cost_of_equity.value)])
      s.rows << CalculationRow.new(:key => "Cost of Debt (%)", :vals => [sprintf("%.2f", 100.0*@after_tax_cost_of_debt.value)])
      s.rows << CalculationRow.new(:key => "Weighted Avg Cost of Capital (%)", :vals => [sprintf("%.2f", 100.0*@rate.value)])

      return s
    end
  end
end
