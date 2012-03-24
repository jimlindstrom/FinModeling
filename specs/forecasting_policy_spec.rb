# forecasting_policy_spec.rb

require 'spec_helper'

describe FinModeling::ForecastingPolicy  do
  before (:all) do
    @company = FinModeling::Company.find("aapl")
    @filings = FinModeling::CompanyFilings.new(@company.filings_since_date(Time.parse("2010-10-01")))
    @policy = FinModeling::ForecastingPolicy.new
  end

  describe ".revenue_growth" do
    subject { @policy.revenue_growth }
    it { should be_an_instance_of Float }
    it { should be_within(0.01).of(0.04) } # FIXME: Make this not hard-coded
  end

  describe ".sales_pm" do
    subject { @policy.sales_pm }
    it { should be_an_instance_of Float }
    it { should be_within(0.01).of(0.20) } # FIXME: Make this not hard-coded
  end

  describe ".fi_over_nfa" do
    subject { @policy.fi_over_nfa }
    it { should be_an_instance_of Float }
    it { should be_within(0.01).of(0.01) } # FIXME: Make this not hard-coded
  end

  describe ".sales_over_noa" do
    subject { @policy.sales_over_noa }
    it { should be_an_instance_of Float }
    it { should be_within(0.01).of(2.00) } # FIXME: Make this not hard-coded
  end
end
