# reformulated_income_statement_spec.rb

require 'spec_helper'

describe FinModeling::ReformulatedIncomeStatement  do
  before(:all) do
    google_2011_annual_rpt = "http://www.sec.gov/Archives/edgar/data/1288776/000119312512025336/0001193125-12-025336-index.htm"
    filing = FinModeling::AnnualReportFiling.download google_2011_annual_rpt
    @inc_stmt = filing.income_statement
    @period = @inc_stmt.periods.last
    @reformed_inc_stmt = filing.income_statement.reformulated(@period)
  end

  describe "operating_revenues" do
    it "returns a CalculationSummary" do
      @reformed_inc_stmt.operating_revenues.should be_an_instance_of FinModeling::CalculationSummary
    end
    it "totals up to the right amount" do
      @reformed_inc_stmt.operating_revenues.total.should be_within(0.1).of(37905000000.0)
    end
  end

  describe "cost_of_revenues" do
    it "returns a CalculationSummary" do
      @reformed_inc_stmt.cost_of_revenues.should be_an_instance_of FinModeling::CalculationSummary
    end
    it "totals up to the right amount" do
      @reformed_inc_stmt.cost_of_revenues.total.should be_within(0.1).of(-13188000000.0)
    end
  end

  describe "gross_revenue" do
    it "returns a CalculationSummary" do
      @reformed_inc_stmt.gross_revenue.should be_an_instance_of FinModeling::CalculationSummary
    end
    it "totals up to the right amount" do
      @reformed_inc_stmt.gross_revenue.total.should be_within(0.1).of(24717000000.0)
    end
  end

  describe "operating_expenses" do
    it "returns a CalculationSummary" do
      @reformed_inc_stmt.operating_expenses.should be_an_instance_of FinModeling::CalculationSummary
    end
    it "totals up to the right amount" do
      @reformed_inc_stmt.operating_expenses.total.should be_within(0.1).of(-12475000000.0)
    end
  end

  describe "income_from_sales_before_tax" do
    it "returns a CalculationSummary" do
      @reformed_inc_stmt.income_from_sales_before_tax.should be_an_instance_of FinModeling::CalculationSummary
    end
    it "totals up to the right amount" do
      @reformed_inc_stmt.income_from_sales_before_tax.total.should be_within(0.1).of(12242000000.0)
    end
  end

  describe "income_from_sales_after_tax" do
    it "returns a CalculationSummary" do
      @reformed_inc_stmt.income_from_sales_after_tax.should be_an_instance_of FinModeling::CalculationSummary
    end
    it "totals up to the right amount" do
      @reformed_inc_stmt.income_from_sales_after_tax.total.should be_within(0.1).of(9682400000.0)
    end
  end

  describe "operating_income_after_tax" do
    it "returns a CalculationSummary" do
      @reformed_inc_stmt.operating_income_after_tax.should be_an_instance_of FinModeling::CalculationSummary
    end
    it "totals up to the right amount" do
      @reformed_inc_stmt.operating_income_after_tax.total.should be_within(0.1).of(9357400000.0)
    end
  end

  describe "net_financing_income" do
    it "returns a CalculationSummary" do
      @reformed_inc_stmt.net_financing_income.should be_an_instance_of FinModeling::CalculationSummary
    end
    it "totals up to the right amount" do
      @reformed_inc_stmt.net_financing_income.total.should be_within(0.1).of(379600000.0)
    end
  end

  describe "comprehensive_income" do
    it "returns a CalculationSummary" do
      @reformed_inc_stmt.comprehensive_income.should be_an_instance_of FinModeling::CalculationSummary
    end
    it "totals up to the right amount" do
      @reformed_inc_stmt.comprehensive_income.total.should be_within(0.1).of(9737000000.0)
    end
  end

end

