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
    subject { @filings.choose_forecasting_policy }
    it { should be_an_instance_of FinModeling::ForecastingPolicy }
  end

  describe "forecasts" do
    before(:all) do
      @policy = @filings.choose_forecasting_policy
      @num_years = 3
    end
    subject { @filings.forecasts(@policy, @num_years) }
    it { should be_an_instance_of FinModeling::Forecasts }
  end
end
