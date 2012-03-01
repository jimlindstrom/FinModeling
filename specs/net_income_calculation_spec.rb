# income_statement_calculation_spec.rb

require 'spec_helper'

describe FinModeling::NetIncomeCalculation  do
  before(:all) do
    #FinModeling::IncomeStatementItem.load_vectors_and_train(FinModeling::ISI_TRAINING_VECTORS)

    google_2011_annual_rpt = "http://www.sec.gov/Archives/edgar/data/1288776/000119312512025336/0001193125-12-025336-index.htm"
    filing = FinModeling::AnnualReportFiling.download google_2011_annual_rpt
    @inc_stmt = filing.income_statement
    @period = @inc_stmt.periods.last
    @ni = @inc_stmt.net_income_calculation
  end

  describe "summary" do
    it "only requires a period (knows how debts/credits work and whether to flip the total)" do
      @ni.summary(@period).should be_an_instance_of FinModeling::CalculationSummary
    end
    it "tags each row with an Income Statement Type" do
      FinModeling::IncomeStatementItem::ISI_TYPES.include?(@ni.summary(@period).rows.first[:type]).should be_true
    end
  end
end

