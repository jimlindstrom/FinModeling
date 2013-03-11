module FinModeling
  class ReformulatedIncomeStatement
    attr_accessor :period
    attr_accessor :operating_revenues, :cost_of_revenues, :operating_expenses

    def initialize(period, net_income_summary, tax_rate=0.35)
      @period   = period
      @tax_rate = tax_rate

      @operating_revenues = net_income_summary.filter_by_type(:or  )
      @cost_of_revenues   = net_income_summary.filter_by_type(:cogs)
      @operating_expenses = net_income_summary.filter_by_type(:oe  )
      @oibt  = net_income_summary.filter_by_type(:oibt )
      @fibt  = net_income_summary.filter_by_type(:fibt )
      @tax   = net_income_summary.filter_by_type(:tax  )
      @ooiat = net_income_summary.filter_by_type(:ooiat)
      @fiat  = net_income_summary.filter_by_type(:fiat )
    
      @fibt_tax_effect = (@fibt.total * @tax_rate).round.to_f
      @nfi = @fibt.total + -@fibt_tax_effect + @fiat.total
    
      @oibt_tax_effect = (@oibt.total * @tax_rate).round.to_f
    
      @gm = @operating_revenues.total + @cost_of_revenues.total
      @oisbt = @gm + @operating_expenses.total
    
      @oisat = @oisbt + @tax.total + @fibt_tax_effect + @oibt_tax_effect
    
      @oi = @oisat + @oibt.total - @oibt_tax_effect + @ooiat.total
    
      @ci = @nfi + @oi
    end

    def -(ris2)
      net_income_summary = NetIncomeSummaryFromDifferences.new(self, ris2)
      return ReformulatedIncomeStatement.new(@period, net_income_summary, @tax_rate)
    end

    def gross_revenue
      cs = FinModeling::CalculationSummary.new
      cs.title = "Gross Revenue"
      cs.rows = [ CalculationRow.new(:key => "Operating Revenues (OR)",   :vals => [@operating_revenues.total] ),
                  CalculationRow.new(:key => "Cost of Goods Sold (COGS)", :vals => [@cost_of_revenues.total] ) ]
      return cs
    end

    def income_from_sales_before_tax
      cs = FinModeling::CalculationSummary.new
      cs.title = "Operating Income from sales, before tax (OISBT)"
      cs.rows = [ CalculationRow.new(:key => "Gross Margin (GM)", :vals => [@gm] ),
                  CalculationRow.new(:key => "Operating Expense (OE)", :vals => [@operating_expenses.total] ) ]
      return cs
    end

    def income_from_sales_after_tax
      cs = FinModeling::CalculationSummary.new
      cs.title = "Operating Income from sales, after tax (OISAT)"
      cs.rows = [ CalculationRow.new(:key => "Operating income from sales (before tax)", :vals => [@oisbt] ),
                  CalculationRow.new(:key => "Reported taxes", :vals => [@tax.total] ),
                  CalculationRow.new(:key => "Taxes on net financing income", :vals => [@fibt_tax_effect] ),
                  CalculationRow.new(:key => "Taxes on other operating income", :vals => [@oibt_tax_effect] ) ]
      return cs
    end

    def operating_income_after_tax
      cs = FinModeling::CalculationSummary.new
      cs.title = "Operating income, after tax (OI)"
      cs.rows = [ CalculationRow.new(:key => "Operating income after sales, after tax (OISAT)", :vals => [@oisat] ),
                  CalculationRow.new(:key => "Other operating income, before tax (OIBT)", :vals => [@oibt.total] ),
                  CalculationRow.new(:key => "Tax on other operating income", :vals => [-@oibt_tax_effect] ),
                  CalculationRow.new(:key => "Other operating income, after tax (OOIAT)", :vals => [@ooiat.total] ) ]
      return cs
    end

    def net_financing_income
      cs = FinModeling::CalculationSummary.new
      cs.title = "Net financing income, after tax (NFI)"
      cs.rows = [ CalculationRow.new(:key => "Financing income, before tax (FIBT)", :vals => [@fibt.total] ),
                  CalculationRow.new(:key => "Tax effect (FIBT_TAX_EFFECT)", :vals => [-@fibt_tax_effect] ),
                  CalculationRow.new(:key => "Financing income, after tax (FIAT)", :vals => [@fiat.total] ) ]
      return cs
    end

    def comprehensive_income
      cs = FinModeling::CalculationSummary.new
      cs.title = "Comprehensive income (CI)"
      cs.rows = [ CalculationRow.new(:key => "Operating income, after tax (OI)", :vals => [@oi] ),
                  CalculationRow.new(:key => "Net financing income, after tax (NFI)", :vals => [@nfi] ) ]
      return cs
    end

    def gross_margin
      gross_revenue.total / operating_revenues.total
    end

    def sales_profit_margin
      income_from_sales_after_tax.total / operating_revenues.total
    end

    def operating_profit_margin
      operating_income_after_tax.total / operating_revenues.total
    end

    def fi_over_sales
      net_financing_income.total / operating_revenues.total
    end

    def ni_over_sales
      comprehensive_income.total / operating_revenues.total
    end

    def sales_over_noa(reformed_bal_sheet)
      ratio = operating_revenues.total / reformed_bal_sheet.net_operating_assets.total
      Ratio.new(ratio).annualize(from_days=@period.days, to_days=365.0)
    end

    def fi_over_nfa(reformed_bal_sheet)
      ratio = net_financing_income.total / reformed_bal_sheet.net_financial_assets.total
      Ratio.new(ratio).annualize(from_days=@period.days, to_days=365.0)
    end

    def revenue_growth(prev)
      rate = (operating_revenues.total - prev.operating_revenues.total) / prev.operating_revenues.total
      return annualize_rate(prev, rate)
    end

    def core_oi_growth(prev)
      rate = (income_from_sales_after_tax.total - prev.income_from_sales_after_tax.total) / prev.income_from_sales_after_tax.total
      return annualize_rate(prev, rate)
    end

    def oi_growth(prev)
      rate = (operating_income_after_tax.total - prev.operating_income_after_tax.total) / prev.operating_income_after_tax.total
      return annualize_rate(prev, rate)
    end

    def re_oi(prev_bal_sheet, expected_rate_of_return=0.10)
      e_ror = deannualize_rate(prev_bal_sheet, expected_rate_of_return)
      return (operating_income_after_tax.total - (e_ror * prev_bal_sheet.net_operating_assets.total))
    end

    def self.empty_analysis
      analysis = CalculationSummary.new
      analysis.title = ""
      analysis.rows = []

      analysis.header_row = CalculationHeader.new(:key => "",    :vals => ["Unknown..."])

      analysis.rows << CalculationRow.new(:key => "Revenue ($MM)",  :vals => [nil])
      if Config.income_detail_enabled?
        analysis.rows << CalculationRow.new(:key => "COGS ($MM)",   :vals => [nil])
        analysis.rows << CalculationRow.new(:key => "GM ($MM)",     :vals => [nil])
        analysis.rows << CalculationRow.new(:key => "OE ($MM)",     :vals => [nil])
        analysis.rows << CalculationRow.new(:key => "OISBT ($MM)",  :vals => [nil])
      end
      analysis.rows << CalculationRow.new(:key => "Core OI ($MM)",  :vals => [nil])
      analysis.rows << CalculationRow.new(:key => "OI ($MM)",       :vals => [nil])
      analysis.rows << CalculationRow.new(:key => "FI ($MM)",       :vals => [nil])
      analysis.rows << CalculationRow.new(:key => "NI ($MM)",       :vals => [nil])
      analysis.rows << CalculationRow.new(:key => "Gross Margin",   :vals => [nil])
      analysis.rows << CalculationRow.new(:key => "Sales PM",       :vals => [nil])
      analysis.rows << CalculationRow.new(:key => "Operating PM",   :vals => [nil])
      analysis.rows << CalculationRow.new(:key => "FI / Sales",     :vals => [nil])
      analysis.rows << CalculationRow.new(:key => "NI / Sales",     :vals => [nil])
      analysis.rows << CalculationRow.new(:key => "Sales / NOA",    :vals => [nil])
      analysis.rows << CalculationRow.new(:key => "FI / NFA",       :vals => [nil])
      analysis.rows << CalculationRow.new(:key => "Revenue Growth", :vals => [nil])
      analysis.rows << CalculationRow.new(:key => "Core OI Growth", :vals => [nil])
      analysis.rows << CalculationRow.new(:key => "OI Growth",      :vals => [nil])
      analysis.rows << CalculationRow.new(:key => "ReOI ($MM)",     :vals => [nil])

      return analysis
    end

    def analysis(re_bs, prev_re_is, prev_re_bs)
      analysis = CalculationSummary.new
      analysis.title = ""
      analysis.rows = []
  
      if re_bs.nil?
        analysis.header_row = CalculationHeader.new(:key => "",   :vals => ["Unknown..."])
      else
        analysis.header_row = CalculationHeader.new(:key => "",   :vals => [re_bs.period.to_pretty_s])
      end
  
      analysis.rows << CalculationRow.new(:key => "Revenue ($MM)",   :vals => [@operating_revenues.total.to_nearest_million])
      if Config.income_detail_enabled?
        analysis.rows << CalculationRow.new(:key => "COGS ($MM)",    :vals => [@cost_of_revenues.total.to_nearest_million])
        analysis.rows << CalculationRow.new(:key => "GM ($MM)",      :vals => [@gm.to_nearest_million])
        analysis.rows << CalculationRow.new(:key => "OE ($MM)",      :vals => [@operating_expenses.total.to_nearest_million])
        analysis.rows << CalculationRow.new(:key => "OISBT ($MM)",   :vals => [income_from_sales_before_tax.total.to_nearest_million])
      end
      analysis.rows << CalculationRow.new(:key => "Core OI ($MM)",   :vals => [income_from_sales_after_tax.total.to_nearest_million])
      analysis.rows << CalculationRow.new(:key => "OI ($MM)",        :vals => [operating_income_after_tax.total.to_nearest_million])
      analysis.rows << CalculationRow.new(:key => "FI ($MM)",        :vals => [net_financing_income.total.to_nearest_million])
      analysis.rows << CalculationRow.new(:key => "NI ($MM)",        :vals => [comprehensive_income.total.to_nearest_million])
      analysis.rows << CalculationRow.new(:key => "Gross Margin",    :vals => [gross_margin])
      analysis.rows << CalculationRow.new(:key => "Sales PM",        :vals => [sales_profit_margin])
      analysis.rows << CalculationRow.new(:key => "Operating PM",    :vals => [operating_profit_margin])
      analysis.rows << CalculationRow.new(:key => "FI / Sales",      :vals => [fi_over_sales])
      analysis.rows << CalculationRow.new(:key => "NI / Sales",      :vals => [ni_over_sales])

      if !prev_re_bs.nil? && !prev_re_is.nil?
        analysis.rows << CalculationRow.new(:key => "Sales / NOA",   :vals => [sales_over_noa(prev_re_bs)])
        analysis.rows << CalculationRow.new(:key => "FI / NFA",      :vals => [fi_over_nfa(   prev_re_bs)])
        analysis.rows << CalculationRow.new(:key => "Revenue Growth",:vals => [revenue_growth(prev_re_is)])
        analysis.rows << CalculationRow.new(:key => "Core OI Growth",:vals => [core_oi_growth(prev_re_is)])
        analysis.rows << CalculationRow.new(:key => "OI Growth",     :vals => [oi_growth(     prev_re_is)])
        analysis.rows << CalculationRow.new(:key => "ReOI ($MM)",    :vals => [re_oi(         prev_re_bs).to_nearest_million])
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

    def self.forecast_next(period, policy, last_re_bs, last_re_is)
      operating_revenues = policy.revenue_on(period.value["end_date"])
      income_from_sales_after_tax = operating_revenues * policy.sales_pm_on(period.value["end_date"])
      net_financing_income = last_re_bs.net_financial_assets.total * Ratio.new(policy.fi_over_nfa_on(period.value["end_date"])).yearly_to_quarterly
      comprehensive_income = income_from_sales_after_tax + net_financing_income

      ForecastedReformulatedIncomeStatement.new(period, operating_revenues, 
                                                income_from_sales_after_tax,
                                                net_financing_income, comprehensive_income)
    end

    private

    def annualize_rate(prev, rate)
      from_days = case
        when prev.period.is_instant?
          Xbrlware::DateUtil.days_between(prev.period.value,             @period.value["end_date"])
        when prev.period.is_duration?
          Xbrlware::DateUtil.days_between(prev.period.value["end_date"], @period.value["end_date"])
      end
      Rate.new(rate).annualize(from_days, to_days=365)
    end

    def deannualize_rate(prev, rate)
      to_days = case
        when prev.period.is_instant?
          Xbrlware::DateUtil.days_between(prev.period.value,             @period.value["end_date"])
        when prev.period.is_duration?
          Xbrlware::DateUtil.days_between(prev.period.value["end_date"], @period.value["end_date"])
      end
      Rate.new(rate).annualize(from_days=365, to_days)
    end

  end

end
