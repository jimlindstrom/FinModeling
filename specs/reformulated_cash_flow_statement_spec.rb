# reformulated_income_statement_spec.rb

require 'spec_helper'

describe FinModeling::ReformulatedCashFlowStatement  do
  before(:all) do
    google_2011_annual_rpt = "http://www.sec.gov/Archives/edgar/data/1288776/000119312512025336/0001193125-12-025336-index.htm"
    filing = FinModeling::AnnualReportFiling.download google_2011_annual_rpt
    @cash_flow_stmt = filing.cash_flow_statement
    @period = @cash_flow_stmt.periods.last
    @reformed_cash_flow_stmt = @cash_flow_stmt.reformulated(@period)
  end

  describe "new" do
    it "takes a cash change calculation and a period and returns a CalculationSummary" do
      rcfs = FinModeling::ReformulatedCashFlowStatement.new(@period, @cash_flow_stmt.cash_change_calculation.summary(:period=>@period))
      rcfs.should be_an_instance_of FinModeling::ReformulatedCashFlowStatement
    end
  end

  subject { @reformed_cash_flow_stmt }

  describe "cash_from_operations" do
    subject { @reformed_cash_flow_stmt.cash_from_operations }
    it { should be_an_instance_of FinModeling::CalculationSummary }
    it "totals up the values of rows with type :c" do
      sum = @cash_flow_stmt.cash_change_calculation
                           .summary(:period=>@period)
                           .rows.select{ |row| row.type == :c }
                           .map{ |row| row.val }
                           .inject(:+)
      subject.total.should == sum
    end
  end

  describe "cash_investments_in_operations" do
    subject { @reformed_cash_flow_stmt.cash_investments_in_operations }
    it { should be_an_instance_of FinModeling::CalculationSummary }
    it "totals up the values of rows with type :i" do
      sum = @cash_flow_stmt.cash_change_calculation
                           .summary(:period=>@period)
                           .rows.select{ |row| row.type == :i }
                           .map{ |row| row.val }
                           .inject(:+)
      subject.total.should == sum
    end
  end

  describe "payments_to_debtholders" do
    subject { @reformed_cash_flow_stmt.payments_to_debtholders }
    it { should be_an_instance_of FinModeling::CalculationSummary }
    it "totals up the values of rows with type :d, minus the total change in cash" do
      sum = @cash_flow_stmt.cash_change_calculation
                           .summary(:period=>@period)
                           .rows.select{ |row| row.type == :d }
                           .map{ |row| row.val }
                           .inject(:+) 
      sum = sum - @cash_flow_stmt.cash_change_calculation
                           .summary(:period=>@period)
                           .total
      subject.total.should == sum
    end
  end

  describe "payments_to_stockholders" do
    subject { @reformed_cash_flow_stmt.payments_to_stockholders }
    it { should be_an_instance_of FinModeling::CalculationSummary }
    it "totals up the values of rows with type :f" do
      sum = @cash_flow_stmt.cash_change_calculation
                           .summary(:period=>@period)
                           .rows.select{ |row| row.type == :f }
                           .map{ |row| row.val }
                           .inject(:+)
      subject.total.should == sum
    end
  end

  describe "free_cash_flow" do
    subject { @reformed_cash_flow_stmt.free_cash_flow }
    it { should be_an_instance_of FinModeling::CalculationSummary }
    it "totals up cash from operations and cash investments in operations" do
      subject.total.should == ( @reformed_cash_flow_stmt.cash_from_operations.total + 
                                @reformed_cash_flow_stmt.cash_investments_in_operations.total )
    end
  end

  describe "financing_flows" do
    subject { @reformed_cash_flow_stmt.financing_flows }
    it { should be_an_instance_of FinModeling::CalculationSummary }
    it "totals up payments to both debtholders and stockholders" do
      subject.total.should == ( @reformed_cash_flow_stmt.payments_to_debtholders.total + 
                                @reformed_cash_flow_stmt.payments_to_stockholders.total )
    end
  end

end

