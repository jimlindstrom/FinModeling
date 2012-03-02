# income_statement_calculation_spec.rb

require 'spec_helper'

describe FinModeling::IncomeStatementCalculation  do
  before(:all) do
    google_2011_annual_rpt = "http://www.sec.gov/Archives/edgar/data/1288776/000119312512025336/0001193125-12-025336-index.htm"
    filing = FinModeling::AnnualReportFiling.download google_2011_annual_rpt
    @inc_stmt = filing.income_statement
    @period = @inc_stmt.periods.last
  end

  describe "net_income_calculation" do
    it "returns a NetIncomeCalculation" do
      @inc_stmt.net_income_calculation.should be_an_instance_of FinModeling::NetIncomeCalculation
    end
    it "returns the root node of the net income calculation" do
      @inc_stmt.net_income_calculation.label.downcase.should match /net.*income/
    end
  end

  describe "is_valid?" do
    it "returns false if none of the net income leaf nodes contains the term 'tax'" do
      # FIXME: need an example of this. the EA one actually *does* have a tax item.
      ea_2011_annual_rpt = "http://www.sec.gov/Archives/edgar/data/712515/000119312511149262/0001193125-11-149262-index.htm"
      filing = FinModeling::AnnualReportFiling.download ea_2011_annual_rpt
      #filing.income_statement.is_valid?.should be_false
      pending
    end
    it "returns false if none of the net income leaf nodes contains the terms 'sales' or 'revenue'" do
      timewarner_2011_annual_rpt = "http://www.sec.gov/Archives/edgar/data/1105705/000119312512077072/0001193125-12-077072-index.htm"
      filing = FinModeling::AnnualReportFiling.download timewarner_2011_annual_rpt
      filing.income_statement.is_valid?.should be_false
    end
    it "returns true otherwise" do
      google_2011_annual_rpt = "http://www.sec.gov/Archives/edgar/data/1288776/000119312512025336/0001193125-12-025336-index.htm"
      filing = FinModeling::AnnualReportFiling.download google_2011_annual_rpt
      filing.income_statement.is_valid?.should be_true
    end
  end
end

