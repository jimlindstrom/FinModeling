module FinModeling
  class ReformulatedIncomeStatement

    def initialize(net_income_summary, tax_rate=0.35)
      @tax_rate = tax_rate

      @orev  = net_income_summary.filter_by_type(:or   )
      @cogs  = net_income_summary.filter_by_type(:cogs )
      @oe    = net_income_summary.filter_by_type(:oe   )
      @oibt  = net_income_summary.filter_by_type(:oibt )
      @fibt  = net_income_summary.filter_by_type(:fibt )
      @tax   = net_income_summary.filter_by_type(:tax  )
      @ooiat = net_income_summary.filter_by_type(:ooiat)
      @fiat  = net_income_summary.filter_by_type(:fiat )
    
      @fibt_tax_effect = (@fibt.total * @tax_rate).round.to_f
      @nfi = @fibt.total + -@fibt_tax_effect + @fiat.total
    
      @oibt_tax_effect = (@oibt.total * @tax_rate).round.to_f
    
      @gm = @orev.total + @cogs.total
      @oisbt = @gm + @oe.total
    
      @oisat = @oisbt + @tax.total + @fibt_tax_effect + @oibt_tax_effect
    
      @oi = @oisat + @oibt.total - @oibt_tax_effect + @ooiat.total
    
      @ci = @nfi + @oi
    
    end

    def operating_revenues
      @orev
    end

    def cost_of_revenues
      @cogs
    end

    def gross_revenue
      cs = FinModeling::CalculationSummary.new
      cs.title = "Gross Revenue"
      cs.rows = [ { :key => "Operating Revenues (OR)", :val => @orev.total },
                  { :key => "Cost of Goods Sold (COGS)", :val => @cogs.total } ]
      return cs

    end

    def operating_expenses
      @oe
    end

    def income_from_sales_before_tax
      cs = FinModeling::CalculationSummary.new
      cs.title = "Operating Income from sales, before tax (OISBT)"
      cs.rows = [ { :key => "Gross Margin (GM)", :val => @gm },
                  { :key => "Operating Expense (OE)", :val => @oe.total } ]
      return cs
    end

    def income_from_sales_after_tax
      cs = FinModeling::CalculationSummary.new
      cs.title = "Operating Income from sales, after tax (OISAT)"
      cs.rows = [ { :key => "Operating income from sales (before tax)", :val => @oisbt },
                  { :key => "Reported taxes", :val => @tax.total },
                  { :key => "Taxes on net financing income", :val => @fibt_tax_effect },
                  { :key => "Taxes on other operating income", :val => @oibt_tax_effect } ]
      return cs
    end

    def operating_income_after_tax
      cs = FinModeling::CalculationSummary.new
      cs.title = "Operating income, after tax (OI)"
      cs.rows = [ { :key => "Operating income after sales, after tax (OISAT)", :val => @oisat },
                  { :key => "Other operating income, before tax (OIBT)", :val => @oibt.total },
                  { :key => "Tax on other operating income", :val => -@oibt_tax_effect },
                  { :key => "Other operating income, after tax (OOIAT)", :val => @ooiat.total } ]
      return cs
    end

    def net_financing_income
      cs = FinModeling::CalculationSummary.new
      cs.title = "Net financing income, after tax (NFI)"
      cs.rows = [ { :key => "Financing income, before tax (FIBT)", :val => @fibt.total },
                  { :key => "Tax effect (FIBT_TAX_EFFECT)", :val => -@fibt_tax_effect },
                  { :key => "Financing income, after tax (FIAT)", :val => @fiat.total } ]
      return cs
    end

    def comprehensive_income
      cs = FinModeling::CalculationSummary.new
      cs.title = "Comprehensive (CI)"
      cs.rows = [ { :key => "Operating income, after tax (OI)", :val => @oi },
                  { :key => "Net financing income, after tax (NFI)", :val => @nfi } ]
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
      operating_revenues.total / reformed_bal_sheet.net_operating_assets.total
    end

    def fi_over_nfa(reformed_bal_sheet)
      net_financing_income.total / reformed_bal_sheet.net_financial_assets.total
    end

    def revenue_growth(prev)
      (operating_revenues.total - prev.operating_revenues.total) / prev.operating_revenues.total
    end

    def core_oi_growth(prev)
      (income_from_sales_after_tax.total - prev.income_from_sales_after_tax.total) / prev.income_from_sales_after_tax.total
    end

    def oi_growth(prev)
      (operating_income_after_tax.total - prev.operating_income_after_tax.total) / prev.operating_income_after_tax.total
    end

    def re_oi(prev_bal_sheet, expected_rate_of_return=0.10)
      operating_income_after_tax.total - (expected_rate_of_return * prev_bal_sheet.net_operating_assets.total)
    end

  end
end
