# company_filings_spec.rb

require 'spec_helper'

describe FinModeling::Forecasts  do
  before (:all) do
    @company = FinModeling::Company.find("aapl")
    @filings = FinModeling::CompanyFilings.new(@company.filings_since_date(Time.parse("2010-10-01")))
    @forecasts = @filings.forecasts(@filings.choose_forecasting_policy(e_ror=0.10), num_quarters=3)
  end

  describe "balance_sheet_analyses" do
    subject { @forecasts.balance_sheet_analyses(@filings) }
    it { should be_a FinModeling::CalculationSummary }
  end

  describe "income_statement_analyses" do
    subject { @forecasts.income_statement_analyses(@filings, e_ror=0.10) }
    it { should be_a FinModeling::CalculationSummary }
  end
end
