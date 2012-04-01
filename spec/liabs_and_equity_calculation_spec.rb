# liabs_and_equity_calculation_spec.rb

require 'spec_helper'

describe FinModeling::LiabsAndEquityCalculation  do
  before(:all) do
    google_2011_annual_rpt = "http://www.sec.gov/Archives/edgar/data/1288776/000119312512025336/0001193125-12-025336-index.htm"
    filing = FinModeling::AnnualReportFiling.download google_2011_annual_rpt
    @bal_sheet = filing.balance_sheet
    @period = @bal_sheet.periods.last
    @lse = @bal_sheet.liabs_and_equity_calculation
  end

  describe "summary" do
    subject { @lse.summary(:period=>@period) }
    it { should be_a FinModeling::CalculationSummary }
  end

  describe ".has_equity_item" do
    pending "Find a test case..."
  end
end

