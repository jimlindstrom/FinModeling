# generic_forecasting_policy_spec.rb

require 'spec_helper'

describe FinModeling::GenericForecastingPolicy  do
  before (:all) do
    @policy = FinModeling::GenericForecastingPolicy.new
  end

  describe ".revenue_growth" do
    subject { @policy.revenue_growth }
    it { should be_a Float }
    it { should be_within(0.01).of(0.04) } # FIXME: Make this not hard-coded
  end

  describe ".sales_pm" do
    subject { @policy.sales_pm }
    it { should be_a Float }
    it { should be_within(0.01).of(0.20) } # FIXME: Make this not hard-coded
  end

  describe ".fi_over_nfa" do
    subject { @policy.fi_over_nfa }
    it { should be_a Float }
    it { should be_within(0.01).of(0.01) } # FIXME: Make this not hard-coded
  end

  describe ".sales_over_noa" do
    subject { @policy.sales_over_noa }
    it { should be_a Float }
    it { should be_within(0.01).of(2.00) } # FIXME: Make this not hard-coded
  end
end
