# liabs_and_equity_calculation_spec.rb

require 'spec_helper'

describe FinModeling::LiabsAndEquityCalculation  do
  before(:all) do
    if RSpec.configuration.use_balance_sheet_factory?
      @bal_sheet = FinModeling::Factory.BalanceSheetCalculation(:sheet => 'google 10-k 2011-12-31 balance sheet')
    else
      google_2011_annual_rpt = "http://www.sec.gov/Archives/edgar/data/1288776/000119312512025336/0001193125-12-025336-index.htm"
      filing = FinModeling::AnnualReportFiling.download google_2011_annual_rpt
      @bal_sheet = filing.balance_sheet
    end
    @period = @bal_sheet.periods.last
    @lse = @bal_sheet.liabs_and_equity_calculation
  end

  describe "summary" do
    it "only requires a period (knows how debts/credits work and whether to flip the total)" do
      @lse.summary(@period).should be_an_instance_of FinModeling::CalculationSummary
    end
  end
end

