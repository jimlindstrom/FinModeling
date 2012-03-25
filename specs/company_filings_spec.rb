# company_filings_spec.rb

require 'spec_helper'

describe FinModeling::CompanyFiling  do
  before (:all) do
    @company = FinModeling::Company.find("aapl")
    @filings = FinModeling::CompanyFilings.new(@company.filings_since_date(Time.parse("2010-10-01")))
  end

  describe "balance_sheet_analyses" do
    subject { @filings.balance_sheet_analyses }
    it { should be_an_instance_of FinModeling::MultiColumnCalculationSummary }
  end

  describe "cash_flow_statement_analyses" do
    subject { @filings.cash_flow_statement_analyses }
    it { should be_an_instance_of FinModeling::MultiColumnCalculationSummary }
  end

  describe "income_statement_analyses" do
    subject { @filings.income_statement_analyses }
    it { should be_an_instance_of FinModeling::MultiColumnCalculationSummary }
  end

  describe "choose_forecasting_policy" do
    context "when one or two filings" do
      let(:filings) { FinModeling::CompanyFilings.new(@filings[-2..-1]) }
      subject { filings.choose_forecasting_policy }

      it { should be_an_instance_of FinModeling::GenericForecastingPolicy }
    end
    context "when two or more filings" do
      let(:filings) { FinModeling::CompanyFilings.new(@filings[-3..-1]) }
      subject { filings.choose_forecasting_policy }
      it { should be_an_instance_of FinModeling::ConstantForecastingPolicy }

      let(:isa) { filings.income_statement_analyses }

      its(:revenue_growth) { should be_within(0.01).of(isa.revenue_growth_row.valid_vals.mean) }
      its(:sales_pm)       { should be_within(0.01).of(isa.operating_pm_row.valid_vals.mean) } # FIXME: name mismatch
      its(:sales_over_noa) { should be_within(0.01).of(isa.asset_turnover_row.valid_vals.mean) } # FIXME: name mismatch
      its(:fi_over_nfa)    { should be_within(0.01).of(isa.fi_over_nfa_row.valid_vals.mean) }
    end
  end

  describe "forecasts" do
    let(:policy) { @filings.choose_forecasting_policy }
    let(:num_quarters) { 3 }
    subject { @filings.forecasts(policy, num_quarters) }
    it { should be_an_instance_of FinModeling::Forecasts }
    its(:reformulated_income_statements) { should have(num_quarters).items }
    its(:reformulated_balance_sheets)    { should have(num_quarters).items }
  end
end
