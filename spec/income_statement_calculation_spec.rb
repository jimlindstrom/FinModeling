# income_statement_calculation_spec.rb

require 'spec_helper'

describe FinModeling::IncomeStatementCalculation  do
  before(:all) do
    google_2010_q3_rpt = "http://www.sec.gov/Archives/edgar/data/1288776/000119312511282235/0001193125-11-282235-index.htm"
    filing_q3 = FinModeling::AnnualReportFiling.download google_2010_q3_rpt
    @prev_inc_stmt = filing_q3.income_statement

    google_2011_annual_rpt = "http://www.sec.gov/Archives/edgar/data/1288776/000119312512025336/0001193125-12-025336-index.htm"
    filing = FinModeling::AnnualReportFiling.download google_2011_annual_rpt
    @inc_stmt = filing.income_statement
    @period = @inc_stmt.periods.last
  end

  describe "net_income_calculation" do
    subject { @inc_stmt.net_income_calculation }
    it { should be_a FinModeling::NetIncomeCalculation }
    its(:label) { should match /net.*income/i }
  end

  describe "is_valid?" do
    context "when no node contains the term 'tax'" do
      #before(:all) do
      #  @inc_stmt_no_taxes = FinModeling::Factory.IncomeStatementCalculation(:sheet => 'google 10-k 2011-12-31 income statement',
      #                                                                       :delete_tax_item => true)
      #end
      it "returns false if none of the net income leaf nodes contains the term 'tax'" do
        #@inc_stmt_no_taxes.is_valid?.should be_false
        pending "no good way of setting up this test..."
      end
    end
    context "when no node contains the terms 'sales' or 'revenue'" do
      #before(:all) do
      #  @inc_stmt_no_sales = FinModeling::Factory.IncomeStatementCalculation(:sheet => 'google 10-k 2011-12-31 income statement',
      #                                                                       :delete_sales_item => true)
      #end
      it "returns false if none of the net income leaf nodes contains the term 'tax'" do
        #@inc_stmt_no_sales.is_valid?.should be_false
        pending "no good way of setting up this test..."
      end
    end
    context "otherwise" do
      subject { @inc_stmt.is_valid? }
      it { should be_true }
    end
  end

  describe "reformulated" do
    subject { @inc_stmt.reformulated(@period) } 
    it { should be_a FinModeling::ReformulatedIncomeStatement }
  end

  describe "latest_quarterly_reformulated" do
    subject{ @inc_stmt.latest_quarterly_reformulated(@prev_inc_stmt) }
    it { should be_a FinModeling::ReformulatedIncomeStatement }
  end

  describe "write_constructor" do
    before(:all) do
      file_name = "/tmp/finmodeling-inc-stmt.rb"
      item_name = "@inc_stmt"
      file = File.open(file_name, "w")
      @inc_stmt.write_constructor(file, item_name)
      file.close

      eval(File.read(file_name))
      @loaded_is = eval(item_name)
    end

    subject { @loaded_is }
    it { should have_the_same_periods_as(@inc_stmt) }
    it { should have_the_same_reformulated_last_total(:net_financing_income).as(@inc_stmt) }
  end

end

