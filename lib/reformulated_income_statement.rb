module FinModeling
  class ReformulatedIncomeStatement
    attr_accessor :period

    class FakeNetIncomeSummary
      def initialize(ris1, ris2)
        @ris1 = ris1
        @ris2 = ris2
      end
      def filter_by_type(key)
        case key
          when :or
            @cs = FinModeling::CalculationSummary.new
            @cs.title = "Operating Revenues"
            @cs.rows = [ CalculationSummaryRow.new(:key => "First  Row", :val =>  @ris1.operating_revenues.total ),
                         CalculationSummaryRow.new(:key => "Second Row", :val => -@ris2.operating_revenues.total ) ]
            return @cs
          when :cogs
            @cs = FinModeling::CalculationSummary.new
            @cs.title = "Cost of Revenues"
            @cs.rows = [ CalculationSummaryRow.new(:key => "First  Row", :val =>  @ris1.cost_of_revenues.total ),
                         CalculationSummaryRow.new(:key => "Second Row", :val => -@ris2.cost_of_revenues.total ) ]
            return @cs
          when :oe
            @cs = FinModeling::CalculationSummary.new
            @cs.title = "Operating Expenses"
            @cs.rows = [ CalculationSummaryRow.new(:key => "First  Row", :val =>  @ris1.operating_expenses.total ),
                         CalculationSummaryRow.new(:key => "Second Row", :val => -@ris2.operating_expenses.total ) ]
            return @cs
          when :oibt
            @cs = FinModeling::CalculationSummary.new
            @cs.title = "Operating Income from Sales, Before taxes"
            @cs.rows = [ CalculationSummaryRow.new(:key => "First  Row", :val =>  @ris1.operating_income_after_tax.rows[1].val ),
                         CalculationSummaryRow.new(:key => "Second Row", :val => -@ris2.operating_income_after_tax.rows[1].val ) ]
            return @cs
          when :fibt
            @cs = FinModeling::CalculationSummary.new
            @cs.title = "Financing Income, Before Taxes"
            @cs.rows = [ CalculationSummaryRow.new(:key => "First  Row", :val =>  @ris1.net_financing_income.rows[0].val ),
                         CalculationSummaryRow.new(:key => "Second Row", :val => -@ris2.net_financing_income.rows[0].val ) ]
            return @cs
          when :tax
            @cs = FinModeling::CalculationSummary.new
            @cs.title = "Taxes"
            @cs.rows = [ CalculationSummaryRow.new(:key => "First  Row", :val =>  @ris1.income_from_sales_after_tax.rows[1].val ),
                         CalculationSummaryRow.new(:key => "Second Row", :val => -@ris2.income_from_sales_after_tax.rows[1].val ) ]
            return @cs
          when :ooiat
            @cs = FinModeling::CalculationSummary.new
            @cs.title = "Other Operating Income, After Taxes"
            @cs.rows = [ CalculationSummaryRow.new(:key => "First  Row", :val =>  @ris1.operating_income_after_tax.rows[3].val ),
                         CalculationSummaryRow.new(:key => "Second Row", :val => -@ris2.operating_income_after_tax.rows[3].val ) ]
            return @cs
          when :fiat
            @cs = FinModeling::CalculationSummary.new
            @cs.title = "Financing Income, After Taxes"
            @cs.rows = [ CalculationSummaryRow.new(:key => "First  Row", :val =>  @ris1.net_financing_income.rows[2].val ),
                         CalculationSummaryRow.new(:key => "Second Row", :val => -@ris2.net_financing_income.rows[2].val ) ]
            return @cs
        end
      end
    end

    def initialize(period, net_income_summary, tax_rate=0.35)
      @period   = period
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

    def -(ris2)
      net_income_summary = FakeNetIncomeSummary.new(self, ris2)
      return ReformulatedIncomeStatement.new(@period, net_income_summary, @tax_rate)
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
      cs.rows = [ CalculationSummaryRow.new(:key => "Operating Revenues (OR)", :val => @orev.total ),
                  CalculationSummaryRow.new(:key => "Cost of Goods Sold (COGS)", :val => @cogs.total ) ]
      return cs

    end

    def operating_expenses
      @oe
    end

    def income_from_sales_before_tax
      cs = FinModeling::CalculationSummary.new
      cs.title = "Operating Income from sales, before tax (OISBT)"
      cs.rows = [ CalculationSummaryRow.new(:key => "Gross Margin (GM)", :val => @gm ),
                  CalculationSummaryRow.new(:key => "Operating Expense (OE)", :val => @oe.total ) ]
      return cs
    end

    def income_from_sales_after_tax
      cs = FinModeling::CalculationSummary.new
      cs.title = "Operating Income from sales, after tax (OISAT)"
      cs.rows = [ CalculationSummaryRow.new(:key => "Operating income from sales (before tax)", :val => @oisbt ),
                  CalculationSummaryRow.new(:key => "Reported taxes", :val => @tax.total ),
                  CalculationSummaryRow.new(:key => "Taxes on net financing income", :val => @fibt_tax_effect ),
                  CalculationSummaryRow.new(:key => "Taxes on other operating income", :val => @oibt_tax_effect ) ]
      return cs
    end

    def operating_income_after_tax
      cs = FinModeling::CalculationSummary.new
      cs.title = "Operating income, after tax (OI)"
      cs.rows = [ CalculationSummaryRow.new(:key => "Operating income after sales, after tax (OISAT)", :val => @oisat ),
                  CalculationSummaryRow.new(:key => "Other operating income, before tax (OIBT)", :val => @oibt.total ),
                  CalculationSummaryRow.new(:key => "Tax on other operating income", :val => -@oibt_tax_effect ),
                  CalculationSummaryRow.new(:key => "Other operating income, after tax (OOIAT)", :val => @ooiat.total ) ]
      return cs
    end

    def net_financing_income
      cs = FinModeling::CalculationSummary.new
      cs.title = "Net financing income, after tax (NFI)"
      cs.rows = [ CalculationSummaryRow.new(:key => "Financing income, before tax (FIBT)", :val => @fibt.total ),
                  CalculationSummaryRow.new(:key => "Tax effect (FIBT_TAX_EFFECT)", :val => -@fibt_tax_effect ),
                  CalculationSummaryRow.new(:key => "Financing income, after tax (FIAT)", :val => @fiat.total ) ]
      return cs
    end

    def comprehensive_income
      cs = FinModeling::CalculationSummary.new
      cs.title = "Comprehensive (CI)"
      cs.rows = [ CalculationSummaryRow.new(:key => "Operating income, after tax (OI)", :val => @oi ),
                  CalculationSummaryRow.new(:key => "Net financing income, after tax (NFI)", :val => @nfi ) ]
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
      ratio = (operating_revenues.total - prev.operating_revenues.total) / prev.operating_revenues.total
      return annualize_ratio(prev, ratio)
    end

    def core_oi_growth(prev)
      ratio = (income_from_sales_after_tax.total - prev.income_from_sales_after_tax.total) / prev.income_from_sales_after_tax.total
      return annualize_ratio(prev, ratio)
    end

    def oi_growth(prev)
      ratio = (operating_income_after_tax.total - prev.operating_income_after_tax.total) / prev.operating_income_after_tax.total
      return annualize_ratio(prev, ratio)
    end

    def re_oi(prev_bal_sheet, expected_rate_of_return=0.10)
      e_ror = deannualize_ratio(prev_bal_sheet, expected_rate_of_return)
      return (operating_income_after_tax.total - (e_ror * prev_bal_sheet.net_operating_assets.total))
    end

    private

    def annualize_ratio(prev, ratio)
      from_days = case
        when prev.period.is_instant?
          Xbrlware::DateUtil.days_between(prev.period.value,             @period.value["end_date"])
        when prev.period.is_duration?
          Xbrlware::DateUtil.days_between(prev.period.value["end_date"], @period.value["end_date"])
      end
      Rate.new(ratio).annualize(from_days, to_days=365)
    end

    def deannualize_ratio(prev, ratio)
      to_days = case
        when prev.period.is_instant?
          Xbrlware::DateUtil.days_between(prev.period.value,             @period.value["end_date"])
        when prev.period.is_duration?
          Xbrlware::DateUtil.days_between(prev.period.value["end_date"], @period.value["end_date"])
      end
      Rate.new(ratio).annualize(from_days=365, to_days)
    end

  end
end
