# income_statement_calculation_spec.rb

require 'spec_helper'

describe FinModeling::IncomeStatementCalculation  do
  before(:all) do
    if RSpec.configuration.use_income_statement_factory?
      @inc_stmt = FinModeling::Factory.IncomeStatementCalculation(:sheet => 'google 10-k 2011-12-31')
    else
      google_2011_annual_rpt = "http://www.sec.gov/Archives/edgar/data/1288776/000119312512025336/0001193125-12-025336-index.htm"
      filing = FinModeling::AnnualReportFiling.download google_2011_annual_rpt
      @inc_stmt = filing.income_statement
    end
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
    context "when no node contains the term 'tax'" do
      before(:all) do
        @inc_stmt_no_taxes = FinModeling::Factory.IncomeStatementCalculation(:sheet => 'google 10-k 2011-12-31',
                                                                             :delete_tax_item => true)
      end
      it "returns false if none of the net income leaf nodes contains the term 'tax'" do
        @inc_stmt_no_taxes.is_valid?.should be_false
      end
    end
    context "when no node contains the terms 'sales' or 'revenue'" do
      before(:all) do
        @inc_stmt_no_sales = FinModeling::Factory.IncomeStatementCalculation(:sheet => 'google 10-k 2011-12-31',
                                                                             :delete_sales_item => true)
      end
      it "returns false if none of the net income leaf nodes contains the term 'tax'" do
        @inc_stmt_no_sales.is_valid?.should be_false
      end
    end
    it "returns true otherwise" do
      @inc_stmt.is_valid?.should be_true
    end
  end

  describe "reformulated" do
    it "takes a period and returns a ReformulatedIncomeStatement" do
      @inc_stmt.reformulated(@period).should be_an_instance_of FinModeling::ReformulatedIncomeStatement
    end
  end
end

