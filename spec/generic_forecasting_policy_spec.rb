# generic_forecasting_policy_spec.rb

require 'spec_helper'

describe FinModeling::GenericForecastingPolicy  do
  before (:all) do
    @opts = { :operating_revenues=>3.0*1000*1000 }
    @policy = FinModeling::GenericForecastingPolicy.new(@opts)
  end
  let(:date) { Date.today }

  describe ".revenue_growth" do
    subject { @policy.revenue_on(date) }
    it { should be_a Float }
    it { should be_within(0.01).of(@opts[:operating_revenues]) }
  end

  describe ".sales_pm" do
    subject { @policy.sales_pm_on(date) }
    it { should be_a Float }
    it { should be_within(0.01).of(0.20) }
  end

  describe ".fi_over_nfa" do
    subject { @policy.fi_over_nfa_on(date) }
    it { should be_a Float }
    it { should be_within(0.01).of(0.01) }
  end

  describe ".sales_over_noa" do
    subject { @policy.sales_over_noa_on(date) }
    it { should be_a Float }
    it { should be_within(0.01).of(2.00) }
  end
end
