module FinModeling
  class ForecastedReformulatedIncomeStatement < ReformulatedIncomeStatement
    def initialize(period, operating_revenues, income_from_sales_after_tax, net_financing_income, comprehensive_income)
      @period = period
      @orev = operating_revenues
      @income_from_sales_after_tax = income_from_sales_after_tax
      @net_financing_income = net_financing_income
      @comprehensive_income = comprehensive_income
    end

    def -(ris2)
      raise RuntimeError.new("not implmeneted")
    end

    def operating_revenues
      cs = FinModeling::CalculationSummary.new
      cs.title = "Operating Revenues"
      cs.rows = [ CalculationRow.new(:key => "Operating Revenues (OR)", :vals => [@orev] ) ]
      return cs
    end

    def cost_of_revenues
      nil
    end

    def gross_revenue
      nil
    end

    def operating_expenses
      nil
    end

    def income_from_sales_before_tax
      nil
    end

    def income_from_sales_after_tax
      cs = FinModeling::CalculationSummary.new
      cs.title = "Operating Income from sales, after tax (OISAT)"
      cs.rows = [ CalculationRow.new(:key => "Operating income from sales (after tax)", :vals => [@income_from_sales_after_tax] ) ]
      return cs
    end

    def operating_income_after_tax
      income_from_sales_after_tax # this simplified version assumes no non-sales operating income
    end

    def net_financing_income
      cs = FinModeling::CalculationSummary.new
      cs.title = "Net financing income, after tax (NFI)"
      cs.rows = [ CalculationRow.new(:key => "Net financing income", :vals => [@net_financing_income] ) ]
      return cs
    end

    def comprehensive_income
      cs = FinModeling::CalculationSummary.new
      cs.title = "Comprehensive Income (CI)"
      cs.rows = [ CalculationRow.new(:key => "Comprehensive income", :vals => [@comprehensive_income] ) ]
      return cs
    end

    def analysis(re_bs, prev_re_is, prev_re_bs, expected_cost_of_capital)
      analysis = CalculationSummary.new
      analysis.title = ""
      analysis.rows = []
  
      if re_bs.nil?
        analysis.header_row = CalculationHeader.new(:key => "",   :vals => ["Unknown..."])
      else
        analysis.header_row = CalculationHeader.new(:key => "",   :vals => [re_bs.period.to_pretty_s + "E"])
      end
  
      analysis.rows << CalculationRow.new(:key => "Revenue ($MM)",   :vals => [operating_revenues.total.to_nearest_million])
      if Config.income_detail_enabled?
        analysis.rows << CalculationRow.new(:key => "COGS ($MM)",    :vals => [nil])
        analysis.rows << CalculationRow.new(:key => "GM ($MM)",      :vals => [nil])
        analysis.rows << CalculationRow.new(:key => "OE ($MM)",      :vals => [nil])
        analysis.rows << CalculationRow.new(:key => "OISBT ($MM)",   :vals => [nil])
      end
      analysis.rows << CalculationRow.new(:key => "Core OI ($MM)",   :vals => [income_from_sales_after_tax.total.to_nearest_million])
      analysis.rows << CalculationRow.new(:key => "OI ($MM)",        :vals => [nil])
      analysis.rows << CalculationRow.new(:key => "FI ($MM)",        :vals => [net_financing_income.total.to_nearest_million])
      analysis.rows << CalculationRow.new(:key => "NI ($MM)",        :vals => [comprehensive_income.total.to_nearest_million])
      analysis.rows << CalculationRow.new(:key => "Gross Margin",    :vals => [nil])
      analysis.rows << CalculationRow.new(:key => "Sales PM",        :vals => [sales_profit_margin])
      analysis.rows << CalculationRow.new(:key => "Operating PM",    :vals => [nil])
      analysis.rows << CalculationRow.new(:key => "FI / Sales",      :vals => [fi_over_sales])
      analysis.rows << CalculationRow.new(:key => "NI / Sales",      :vals => [ni_over_sales])

      if !prev_re_bs.nil? && !prev_re_is.nil?
        analysis.rows << CalculationRow.new(:key => "Sales / NOA",   :vals => [sales_over_noa(prev_re_bs)])
        analysis.rows << CalculationRow.new(:key => "FI / NFA",      :vals => [fi_over_nfa(   prev_re_bs)])
        analysis.rows << CalculationRow.new(:key => "Revenue Growth",:vals => [revenue_growth(prev_re_is)])
        analysis.rows << CalculationRow.new(:key => "Core OI Growth",:vals => [core_oi_growth(prev_re_is)])
        analysis.rows << CalculationRow.new(:key => "OI Growth",     :vals => [nil])
        analysis.rows << CalculationRow.new(:key => "ReOI ($MM)",    :vals => [re_oi(prev_re_bs, expected_cost_of_capital).to_nearest_million])
      else
        analysis.rows << CalculationRow.new(:key => "Sales / NOA",   :vals => [nil])
        analysis.rows << CalculationRow.new(:key => "FI / NFA",      :vals => [nil])
        analysis.rows << CalculationRow.new(:key => "Revenue Growth",:vals => [nil])
        analysis.rows << CalculationRow.new(:key => "Core OI Growth",:vals => [nil])
        analysis.rows << CalculationRow.new(:key => "OI Growth",     :vals => [nil])
        analysis.rows << CalculationRow.new(:key => "ReOI ($MM)",    :vals => [nil])
      end
  
      return analysis
    end
  end
end
