# company_filings_spec.rb

require 'spec_helper'

describe FinModeling::CompanyFilings  do
  before (:all) do
    @company = FinModeling::Company.find("aapl")
    @filings = FinModeling::CompanyFilings.new(@company.filings_since_date(Time.parse("2010-10-01")))
  end

  subject { @filings }
  its(:balance_sheet_analyses) { should be_a FinModeling::BalanceSheetAnalyses }
  its(:cash_flow_statement_analyses) { should be_a FinModeling::CalculationSummary } # FIXME: model this guy the same way...
  its(:income_statement_analyses) {should be_a FinModeling::IncomeStatementAnalyses }

  describe ".choose_forecasting_policy" do
    context "when one or two filings" do
      let(:filings) { FinModeling::CompanyFilings.new(@filings.last(2)) }
      subject { filings.choose_forecasting_policy }

      it { should be_a FinModeling::GenericForecastingPolicy }
    end
    context "when two or more filings" do
      let(:filings) { FinModeling::CompanyFilings.new(@filings.last(3)) }
      subject { filings.choose_forecasting_policy }
      it { should be_a FinModeling::ConstantForecastingPolicy }

      let(:isa) { filings.income_statement_analyses }

      its(:revenue_growth) { should be_within(0.01).of(isa.revenue_growth_row.valid_vals.mean) }
      its(:sales_pm)       { should be_within(0.01).of(isa.operating_pm_row.valid_vals.mean) } # FIXME: name mismatch
      its(:sales_over_noa) { should be_within(0.01).of(isa.sales_over_noa_row.valid_vals.mean) } 
      its(:fi_over_nfa)    { should be_within(0.01).of(isa.fi_over_nfa_row.valid_vals.mean) }
    end
  end

  describe ".forecasts" do
    let(:policy) { @filings.choose_forecasting_policy }
    let(:num_quarters) { 3 }
    subject { @filings.forecasts(policy, num_quarters) }
    it { should be_a FinModeling::Forecasts }
    its(:reformulated_income_statements) { should have(num_quarters).items }
    its(:reformulated_balance_sheets)    { should have(num_quarters).items }
  end
end
