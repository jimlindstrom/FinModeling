# balance_sheet_calculation_spec.rb

require 'spec_helper'

describe FinModeling::CashFlowStatementCalculation  do
  before(:all) do
    google_2011_annual_rpt = "http://www.sec.gov/Archives/edgar/data/1288776/000119312512025336/0001193125-12-025336-index.htm"
    filing = FinModeling::AnnualReportFiling.download(google_2011_annual_rpt)
    @cash_flow_stmt = filing.cash_flow_statement
    @period = @cash_flow_stmt.periods.last
  end

  describe "cash_change_calculation" do
    subject { @cash_flow_stmt.cash_change_calculation }
    it { should be_an_instance_of FinModeling::CashChangeCalculation }
    its(:label) { should match /^cash/i }
  end

  describe "is_valid?" do
    it "returns true if free cash flow matches financing flows and none are zero" do
      re_cfs = @cash_flow_stmt.reformulated(@period)
      flows_are_balanced = (re_cfs.free_cash_flow.total == (-1*re_cfs.financing_flows.total))
      none_are_zero = (re_cfs.cash_from_operations.total           != 0) &&
                      (re_cfs.cash_investments_in_operations.total != 0) &&
                      (re_cfs.payments_to_debtholders.total        != 0) &&
                      (re_cfs.payments_to_stockholders.total       != 0)

      @cash_flow_stmt.is_valid?.should == (flows_are_balanced && none_are_zero)
    end
  end

  describe "reformulated" do
    subject { @cash_flow_stmt.reformulated(@period) }
    it { should be_a FinModeling::ReformulatedCashFlowStatement }
  end

  describe "latest_quarterly_reformulated" do
    before(:all) do
      google_2011_q1_rpt = "http://www.sec.gov/Archives/edgar/data/1288776/000119312511134428/0001193125-11-134428-index.htm"
      @cash_flow_stmt_2011_q1 = FinModeling::AnnualReportFiling.download(google_2011_q1_rpt).cash_flow_statement

      google_2011_q2_rpt = "http://www.sec.gov/Archives/edgar/data/1288776/000119312511199078/0001193125-11-199078-index.htm"
      @cash_flow_stmt_2011_q2 = FinModeling::AnnualReportFiling.download(google_2011_q2_rpt).cash_flow_statement

      google_2011_q3_rpt = "http://www.sec.gov/Archives/edgar/data/1288776/000119312511282235/0001193125-11-282235-index.htm"
      @cash_flow_stmt_2011_q3 = FinModeling::AnnualReportFiling.download(google_2011_q3_rpt).cash_flow_statement
    end
     
    context "when given a Q1 report" do
      subject { @cash_flow_stmt_2011_q1.latest_quarterly_reformulated(nil) }
      it { should be_an_instance_of FinModeling::ReformulatedCashFlowStatement }
      its(:cash_investments_in_operations) { should have_a_plausible_total }
    end
 
    context "when given a Q2 report (and a previous Q1 report)" do
      subject { @cash_flow_stmt_2011_q2.latest_quarterly_reformulated(@cash_flow_stmt_2011_q1) }
      it { should be_an_instance_of FinModeling::ReformulatedCashFlowStatement }
      it "should be valid" do
        subject.cash_investments_in_operations.total.abs.should be > 1.0
      end
    end
 
    context "when given a Q3 report (and a previous Q2 report)" do
      subject { @cash_flow_stmt_2011_q3.latest_quarterly_reformulated(@cash_flow_stmt_2011_q2) }
      it { should be_an_instance_of FinModeling::ReformulatedCashFlowStatement }
      its(:cash_investments_in_operations) { should have_a_plausible_total }
    end
 
    context "when given an annual report (and a previous Q3 report)" do
      subject { @cash_flow_stmt.latest_quarterly_reformulated(@cash_flow_stmt_2011_q3) }
      it { should be_an_instance_of FinModeling::ReformulatedCashFlowStatement }
      its(:cash_investments_in_operations) { should have_a_plausible_total }
    end
  end

  context "after write_constructor()ing it to a file and then eval()ing the results" do
    before(:all) do
      file_name = "/tmp/finmodeling-cash_flow_stmt.rb"
      item_name = "@cfs"
      file = File.open(file_name, "w")
      @cash_flow_stmt.write_constructor(file, item_name)
      file.close

      eval(File.read(file_name))
      @loaded_cfs = eval(item_name)
    end

    subject { @loaded_cfs }
    it { should have_the_same_periods_as(@cash_flow_stmt) }
    its(:cash_change_calculation) { should have_the_same_last_total_as(@cash_flow_stmt.cash_change_calculation) }
  end

end

