# assets_calculation_spec.rb

require 'spec_helper'

describe FinModeling::AssetsCalculation  do
  before(:all) do
    google_2011_annual_rpt = "http://www.sec.gov/Archives/edgar/data/1288776/000119312512025336/0001193125-12-025336-index.htm"
    filing = FinModeling::AnnualReportFiling.download google_2011_annual_rpt
    @bal_sheet = filing.balance_sheet

    @period = @bal_sheet.periods.last
    @a = @bal_sheet.assets_calculation
  end

  describe "summary" do
    it "only requires a period (knows how debts/credits work and whether to flip the total)" do
      @a.summary(@period).should be_an_instance_of FinModeling::CalculationSummary
    end
  end
end

