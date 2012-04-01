# net_income_calculation_spec.rb

require 'spec_helper'

describe FinModeling::NetIncomeCalculation  do
  before(:all) do
    google_2011_annual_rpt = "http://www.sec.gov/Archives/edgar/data/1288776/000119312512025336/0001193125-12-025336-index.htm"
    filing = FinModeling::AnnualReportFiling.download google_2011_annual_rpt
    @period = filing.income_statement.periods.last
    @ni = filing.income_statement.net_income_calculation
  end

  describe ".summary" do
    subject { @ni.summary(:period=>@period) }
    it { should be_a FinModeling::CalculationSummary }
    it "should tag each row with an Income Statement Type" do
      subject.rows.first.type.should be_in(FinModeling::IncomeStatementItem::TYPES) # FIXME: seems weak.
    end
  end

  describe ".has_revenue_item?" do
    pending "Find a test case..."
  end

  describe ".has_tax_item?" do
    pending "Find a test case..."
  end
end

