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

    def gross_margin
      cs = FinModeling::CalculationSummary.new
      cs.title = "Gross Margin"
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

  end
end
