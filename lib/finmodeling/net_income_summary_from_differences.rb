module FinModeling

  class NetIncomeSummaryFromDifferences
    def initialize(ris1, ris2)
      @ris1 = ris1
      @ris2 = ris2
    end

    def filter_by_type(key)
      cs = FinModeling::CalculationSummary.new
      case key
        when :or
          cs.title = "Operating Revenues"
          cs.rows = [ CalculationRow.new(:key => "First  Row", :vals => [ @ris1.operating_revenues.total] ),
                      CalculationRow.new(:key => "Second Row", :vals => [-@ris2.operating_revenues.total] ) ]
        when :cogs
          cs.title = "Cost of Revenues"
          cs.rows = [ CalculationRow.new(:key => "First  Row", :vals => [ @ris1.cost_of_revenues.total] ),
                      CalculationRow.new(:key => "Second Row", :vals => [-@ris2.cost_of_revenues.total] ) ]
        when :oe
          cs.title = "Operating Expenses"
          cs.rows = [ CalculationRow.new(:key => "First  Row", :vals => [ @ris1.operating_expenses.total] ),
                      CalculationRow.new(:key => "Second Row", :vals => [-@ris2.operating_expenses.total] ) ]
        when :oibt
          cs.title = "Operating Income from Sales, Before taxes"
          cs.rows = [ CalculationRow.new(:key => "First  Row", :vals => [ @ris1.operating_income_after_tax.rows[1].vals.first] ),
                      CalculationRow.new(:key => "Second Row", :vals => [-@ris2.operating_income_after_tax.rows[1].vals.first] ) ]
        when :fibt
          cs.title = "Financing Income, Before Taxes"
          cs.rows = [ CalculationRow.new(:key => "First  Row", :vals => [ @ris1.net_financing_income.rows[0].vals.first] ),
                      CalculationRow.new(:key => "Second Row", :vals => [-@ris2.net_financing_income.rows[0].vals.first] ) ]
        when :tax
          cs.title = "Taxes"
          cs.rows = [ CalculationRow.new(:key => "First  Row", :vals => [ @ris1.income_from_sales_after_tax.rows[1].vals.first] ),
                      CalculationRow.new(:key => "Second Row", :vals => [-@ris2.income_from_sales_after_tax.rows[1].vals.first] ) ]
        when :ooiat
          cs.title = "Other Operating Income, After Taxes"
          cs.rows = [ CalculationRow.new(:key => "First  Row", :vals => [ @ris1.operating_income_after_tax.rows[3].vals.first] ),
                      CalculationRow.new(:key => "Second Row", :vals => [-@ris2.operating_income_after_tax.rows[3].vals.first] ) ]
        when :fiat
          cs.title = "Financing Income, After Taxes"
          cs.rows = [ CalculationRow.new(:key => "First  Row", :vals => [ @ris1.net_financing_income.rows[2].vals.first] ),
                      CalculationRow.new(:key => "Second Row", :vals => [-@ris2.net_financing_income.rows[2].vals.first] ) ]
        else
          return nil
      end
      return cs
    end
  end

end
