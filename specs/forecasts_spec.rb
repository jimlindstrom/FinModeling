# company_filings_spec.rb

require 'spec_helper'

describe FinModeling::Forecasts  do
  before (:all) do
    @company = FinModeling::Company.find("aapl")
    @filings = FinModeling::CompanyFilings.new(@company.filings_since_date(Time.parse("2010-10-01")))
    @policy = @filings.choose_forecasting_policy
    @num_quarters = 3
    @forecasts = @filings.forecasts(@policy, @num_quarters)
  end

  describe "balance_sheet_analyses" do
    subject { @forecasts.balance_sheet_analyses }
    it { should be_a FinModeling::MultiColumnCalculationSummary }
  end

  describe "income_statement_analyses" do
    subject { @forecasts.income_statement_analyses }
    it { should be_a FinModeling::MultiColumnCalculationSummary }
  end
end
