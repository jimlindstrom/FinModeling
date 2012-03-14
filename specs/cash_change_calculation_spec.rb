# cash_change_calculation_spec.rb

require 'spec_helper'

describe FinModeling::CashChangeCalculation  do
  before(:all) do
    google_2011_annual_rpt = "http://www.sec.gov/Archives/edgar/data/1288776/000119312512025336/0001193125-12-025336-index.htm"
    filing = FinModeling::AnnualReportFiling.download(google_2011_annual_rpt, do_caching=false) # FIXME: turn caching back on..
    @cash_flow_stmt = filing.cash_flow_statement
    @period = @cash_flow_stmt.periods.last
    @cash_changes = @cash_flow_stmt.cash_change_calculation
  end

  describe "summary" do
    it "only requires a period (knows how debts/credits work and whether to flip the total)" do
      @cash_changes.summary(@period).should be_an_instance_of FinModeling::CalculationSummary
    end
  end
end

