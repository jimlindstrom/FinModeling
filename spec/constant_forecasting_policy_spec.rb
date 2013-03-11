require 'spec_helper'

describe FinModeling::ConstantForecastingPolicy  do
  before (:all) do
    @vals = { :revenue_estimator        => FinModeling::TimeSeriesEstimator.new(0.04, 0.0),
              :sales_pm_estimator       => FinModeling::TimeSeriesEstimator.new(0.20, 0.0),
              :fi_over_nfa_estimator    => FinModeling::TimeSeriesEstimator.new(0.01, 0.0),
              :sales_over_noa_estimator => FinModeling::TimeSeriesEstimator.new(2.00, 0.0) }
  end

  let(:policy) { FinModeling::ConstantForecastingPolicy.new(@vals) }
  let(:date) { Date.today }

  describe ".revenue_on" do
    subject { policy.revenue_on(date) }
    it { should be_a Float }
    it { should be_within(0.01).of(@vals[:revenue_estimator].a) }
  end

  describe ".sales_pm_on" do
    subject { policy.sales_pm_on(date) }
    it { should be_a Float }
    it { should be_within(0.01).of(@vals[:sales_pm_estimator].a) }
  end

  describe ".fi_over_nfa_on" do
    subject { policy.fi_over_nfa_on(date) }
    it { should be_a Float }
    it { should be_within(0.01).of(@vals[:fi_over_nfa_estimator].a) }
  end

  describe ".sales_over_noa_on" do
    subject { policy.sales_over_noa_on(date) }
    it { should be_a Float }
    it { should be_within(0.01).of(@vals[:sales_over_noa_estimator].a) }
  end
end
