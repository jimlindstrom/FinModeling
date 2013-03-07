# constant_forecasting_policy_spec.rb

require 'spec_helper'

describe FinModeling::ConstantForecastingPolicy  do
  before (:all) do
    @vals = { :revenue_growth => 0.04,
              :sales_pm       => 0.20,
              :fi_over_nfa    => 0.01,
              :sales_over_noa => 2.00 }
    @policy = FinModeling::ConstantForecastingPolicy.new(@vals)
  end

  describe ".revenue_growth" do
    subject { @policy.revenue_growth }
    it { should be_a Float }
    it { should be_within(0.01).of(@vals[:revenue_growth]) }
  end

  describe ".sales_pm" do
    subject { @policy.sales_pm }
    it { should be_a Float }
    it { should be_within(0.01).of(@vals[:sales_pm]) }
  end

  describe ".fi_over_nfa" do
    subject { @policy.fi_over_nfa }
    it { should be_a Float }
    it { should be_within(0.01).of(@vals[:fi_over_nfa]) }
  end

  describe ".sales_over_noa" do
    subject { @policy.sales_over_noa }
    it { should be_a Float }
    it { should be_within(0.01).of(@vals[:sales_over_noa]) }
  end
end
