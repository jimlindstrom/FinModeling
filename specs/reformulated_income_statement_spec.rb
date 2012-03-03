# reformulated_income_statement_spec.rb

require 'spec_helper'

describe FinModeling::ReformulatedIncomeStatement  do
  before(:all) do
    google_2010_annual_rpt = "http://www.sec.gov/Archives/edgar/data/1288776/000119312510030774/0001193125-10-030774-index.htm"
    filing_2010 = FinModeling::AnnualReportFiling.download google_2010_annual_rpt

    @inc_stmt_2010 = filing_2010.income_statement
    is_period_2010 = @inc_stmt_2010.periods.last
    @reformed_inc_stmt_2010 = filing_2010.income_statement.reformulated(is_period_2010)

    bal_sheet_2010 = filing_2010.balance_sheet
    bs_period_2010 = bal_sheet_2010.periods.last
    @reformed_bal_sheet_2010 = filing_2010.balance_sheet.reformulated(bs_period_2010)

    google_2011_annual_rpt = "http://www.sec.gov/Archives/edgar/data/1288776/000119312512025336/0001193125-12-025336-index.htm"
    filing_2011 = FinModeling::AnnualReportFiling.download google_2011_annual_rpt

    @inc_stmt_2011 = filing_2011.income_statement
    is_period_2011 = @inc_stmt_2011.periods.last
    @reformed_inc_stmt_2011 = filing_2011.income_statement.reformulated(is_period_2011)

    bal_sheet_2011 = filing_2011.balance_sheet
    bs_period_2011 = bal_sheet_2011.periods.last
    @reformed_bal_sheet_2011 = filing_2011.balance_sheet.reformulated(bs_period_2011)
  end

  describe "operating_revenues" do
    it "returns a CalculationSummary" do
      @reformed_inc_stmt_2011.operating_revenues.should be_an_instance_of FinModeling::CalculationSummary
    end
    it "totals up to the right amount" do
      @reformed_inc_stmt_2011.operating_revenues.total.should be_within(0.1).of(37905000000.0)
    end
  end

  describe "cost_of_revenues" do
    it "returns a CalculationSummary" do
      @reformed_inc_stmt_2011.cost_of_revenues.should be_an_instance_of FinModeling::CalculationSummary
    end
    it "totals up to the right amount" do
      @reformed_inc_stmt_2011.cost_of_revenues.total.should be_within(0.1).of(-13188000000.0)
    end
  end

  describe "gross_revenue" do
    it "returns a CalculationSummary" do
      @reformed_inc_stmt_2011.gross_revenue.should be_an_instance_of FinModeling::CalculationSummary
    end
    it "totals up to the right amount" do
      @reformed_inc_stmt_2011.gross_revenue.total.should be_within(0.1).of(24717000000.0)
    end
  end

  describe "operating_expenses" do
    it "returns a CalculationSummary" do
      @reformed_inc_stmt_2011.operating_expenses.should be_an_instance_of FinModeling::CalculationSummary
    end
    it "totals up to the right amount" do
      @reformed_inc_stmt_2011.operating_expenses.total.should be_within(0.1).of(-12475000000.0)
    end
  end

  describe "income_from_sales_before_tax" do
    it "returns a CalculationSummary" do
      @reformed_inc_stmt_2011.income_from_sales_before_tax.should be_an_instance_of FinModeling::CalculationSummary
    end
    it "totals up to the right amount" do
      @reformed_inc_stmt_2011.income_from_sales_before_tax.total.should be_within(0.1).of(12242000000.0)
    end
  end

  describe "income_from_sales_after_tax" do
    it "returns a CalculationSummary" do
      @reformed_inc_stmt_2011.income_from_sales_after_tax.should be_an_instance_of FinModeling::CalculationSummary
    end
    it "totals up to the right amount" do
      @reformed_inc_stmt_2011.income_from_sales_after_tax.total.should be_within(0.1).of(9682400000.0)
    end
  end

  describe "operating_income_after_tax" do
    it "returns a CalculationSummary" do
      @reformed_inc_stmt_2011.operating_income_after_tax.should be_an_instance_of FinModeling::CalculationSummary
    end
    it "totals up to the right amount" do
      @reformed_inc_stmt_2011.operating_income_after_tax.total.should be_within(0.1).of(9357400000.0)
    end
  end

  describe "net_financing_income" do
    it "returns a CalculationSummary" do
      @reformed_inc_stmt_2011.net_financing_income.should be_an_instance_of FinModeling::CalculationSummary
    end
    it "totals up to the right amount" do
      @reformed_inc_stmt_2011.net_financing_income.total.should be_within(0.1).of(379600000.0)
    end
  end

  describe "comprehensive_income" do
    it "returns a CalculationSummary" do
      @reformed_inc_stmt_2011.comprehensive_income.should be_an_instance_of FinModeling::CalculationSummary
    end
    it "totals up to the right amount" do
      @reformed_inc_stmt_2011.comprehensive_income.total.should be_within(0.1).of(9737000000.0)
    end
  end

  describe "gross_margin" do
    it "returns a float" do
      @reformed_inc_stmt_2011.gross_margin.should be_an_instance_of Float
    end
    it "totals up to the right amount" do
      gm = @reformed_inc_stmt_2011.gross_revenue.total / @reformed_inc_stmt_2011.operating_revenues.total
      @reformed_inc_stmt_2011.gross_margin.should be_within(0.1).of(gm)
    end
  end

  describe "sales_profit_margin" do
    it "returns a float" do
      @reformed_inc_stmt_2011.sales_profit_margin.should be_an_instance_of Float
    end
    it "totals up to the right amount" do
      sales_pm = @reformed_inc_stmt_2011.income_from_sales_after_tax.total / @reformed_inc_stmt_2011.operating_revenues.total
      @reformed_inc_stmt_2011.sales_profit_margin.should be_within(0.1).of(sales_pm)
    end
  end

  describe "operating_profit_margin" do
    it "returns a float" do
      @reformed_inc_stmt_2011.operating_profit_margin.should be_an_instance_of Float
    end
    it "totals up to the right amount" do
      pm = @reformed_inc_stmt_2011.operating_income_after_tax.total / @reformed_inc_stmt_2011.operating_revenues.total
      @reformed_inc_stmt_2011.operating_profit_margin.should be_within(0.1).of(pm)
    end
  end

  describe "fi_over_sales" do
    it "returns a float" do
      @reformed_inc_stmt_2011.fi_over_sales.should be_an_instance_of Float
    end
    it "totals up to the right amount" do
      fi_over_sales = @reformed_inc_stmt_2011.net_financing_income.total / @reformed_inc_stmt_2011.operating_revenues.total
      @reformed_inc_stmt_2011.fi_over_sales.should be_within(0.1).of(fi_over_sales)
    end
  end

  describe "ni_over_sales" do
    it "returns a float" do
      @reformed_inc_stmt_2011.ni_over_sales.should be_an_instance_of Float
    end
    it "totals up to the right amount" do
      ni_over_sales = @reformed_inc_stmt_2011.comprehensive_income.total / @reformed_inc_stmt_2011.operating_revenues.total
      @reformed_inc_stmt_2011.ni_over_sales.should be_within(0.1).of(ni_over_sales)
    end
  end

  describe "sales_over_noa" do
    it "returns a float" do
      @reformed_inc_stmt_2011.sales_over_noa(@reformed_bal_sheet_2011).should be_an_instance_of Float
    end
    it "totals up to the right amount" do
      sales_over_noa = @reformed_inc_stmt_2011.operating_revenues.total / @reformed_bal_sheet_2011.net_operating_assets.total
      @reformed_inc_stmt_2011.sales_over_noa(@reformed_bal_sheet_2011).should be_within(0.1).of(sales_over_noa)
    end
  end

  describe "fi_over_nfa" do
    it "returns a float" do
      @reformed_inc_stmt_2011.fi_over_nfa(@reformed_bal_sheet_2011).should be_an_instance_of Float
    end
    it "totals up to the right amount" do
      fi_over_nfa = @reformed_inc_stmt_2011.net_financing_income.total / @reformed_bal_sheet_2011.net_financial_assets.total
      @reformed_inc_stmt_2011.fi_over_nfa(@reformed_bal_sheet_2011).should be_within(0.1).of(fi_over_nfa)
    end
  end

  describe "revenue_growth" do
    it "returns a float" do
      @reformed_inc_stmt_2011.revenue_growth(@reformed_inc_stmt_2010).should be_an_instance_of Float
    end
    it "totals up to the right amount" do
      growth = @reformed_inc_stmt_2011.operating_revenues.total - @reformed_inc_stmt_2010.operating_revenues.total
      growth = growth / @reformed_inc_stmt_2010.operating_revenues.total
      @reformed_inc_stmt_2011.revenue_growth(@reformed_inc_stmt_2010).should be_within(0.1).of(growth)
    end
  end

  describe "core_oi_growth" do
    it "returns a float" do
      @reformed_inc_stmt_2011.core_oi_growth(@reformed_inc_stmt_2010).should be_an_instance_of Float
    end
    it "totals up to the right amount" do
      growth = @reformed_inc_stmt_2011.income_from_sales_after_tax.total - @reformed_inc_stmt_2010.income_from_sales_after_tax.total
      growth = growth / @reformed_inc_stmt_2010.income_from_sales_after_tax.total
      @reformed_inc_stmt_2011.core_oi_growth(@reformed_inc_stmt_2010).should be_within(0.1).of(growth)
    end
  end

  describe "oi_growth" do
    it "returns a float" do
      @reformed_inc_stmt_2011.oi_growth(@reformed_inc_stmt_2010).should be_an_instance_of Float
    end
    it "totals up to the right amount" do
      growth = @reformed_inc_stmt_2011.operating_income_after_tax.total - @reformed_inc_stmt_2010.operating_income_after_tax.total
      growth = growth / @reformed_inc_stmt_2010.operating_income_after_tax.total
      @reformed_inc_stmt_2011.oi_growth(@reformed_inc_stmt_2010).should be_within(0.1).of(growth)
    end
  end

  describe "re_oi" do
    before(:all) do
      @expected_rate_of_return = 0.10
    end
    it "returns a float" do
      @reformed_inc_stmt_2011.re_oi(@reformed_bal_sheet_2010, @expected_rate_of_return).should be_an_instance_of Float
    end
    it "totals up to the right amount" do
      last_years_noa = @reformed_bal_sheet_2010.net_operating_assets.total
      expected_rate_of_return = 0.10
      re_oi = @reformed_inc_stmt_2011.operating_income_after_tax.total - (expected_rate_of_return * last_years_noa)
      @reformed_inc_stmt_2011.re_oi(@reformed_bal_sheet_2010, @expected_rate_of_return).should be_within(0.1).of(re_oi)
    end
  end

end

