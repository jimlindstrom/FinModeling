# income_statement_calculation_spec.rb

require 'spec_helper'

describe FinModeling::IncomeStatementCalculation  do
  before(:all) do
    google_2011_annual_rpt = "http://www.sec.gov/Archives/edgar/data/1288776/000119312512025336/0001193125-12-025336-index.htm"
    filing = FinModeling::AnnualReportFiling.download google_2011_annual_rpt
    @inc_stmt = filing.income_statement
    @period = @inc_stmt.periods.last
  end

  describe "operating_expenses" do
    it "returns the root node of the operating expenses calculation" do
      @inc_stmt.operating_expenses.label.downcase.should match /expense/
    end
  end

  describe "operating_income" do
    it "returns the root node of the operating income calculation" do
      @inc_stmt.operating_income.label.downcase.should match /operating.*income/
    end
  end

  describe "net_income" do
    it "returns the root node of the net income calculation" do
      @inc_stmt.net_income.label.downcase.should match /net.*income/
    end
    #it "sums to the same value as do the liabilities and equity" do
    #  left_sum = @inc_stmt.assets.leaf_items(@period).map{|x| x.value.to_f}.inject(:+)
    #  right_sum = @inc_stmt.liabs_and_equity.leaf_items(@period).map{|x| x.value.to_f}.inject(:+)
    #  left_sum.should == right_sum
    #end
  end
end

