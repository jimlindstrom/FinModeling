require 'spec_helper'

describe FinModeling::TimeSeriesEstimator do

  describe ".new" do
    let(:a) { 1.0 }
    let(:b) { 0.2 }
    subject { FinModeling::TimeSeriesEstimator.new(a, b) }

    it { should be_a FinModeling::TimeSeriesEstimator }
    its(:a) { should be_within(0.01).of(a) }
    its(:b) { should be_within(0.01).of(b) }
  end

  describe ".estimate_on" do
    let(:a) { 1.0 }
    let(:b) { 0.2 }
    let(:estimator) { FinModeling::TimeSeriesEstimator.new(a, b) }

    context "when predicting today's outcome" do
      let(:date) { Date.today }
      subject { estimator.estimate_on(date) }

      it { should be_a Float }
      it { should be_within(0.01).of(a) }
    end

    context "when predicting any other day" do
      let(:date) { Date.parse("2014-01-01") }
      let(:num_days) { date - Date.today }
      subject { estimator.estimate_on(date) }

      it { should be_a Float }
      it { should be_within(0.01).of(a + (b*num_days)) }
    end
  end

  describe "#from_time_series" do
    let(:ys) { [ 10, 20 ] }
    let(:dates) { [ (Date.today - 1), (Date.today) ] }
    subject { FinModeling::TimeSeriesEstimator.from_time_series(dates, ys) }
    let(:expected_a) { 20 }
    let(:expected_b) { 20-10 }

    it { should be_a FinModeling::TimeSeriesEstimator }
    its(:a) { should be_within(0.01).of(expected_a) }
    its(:b) { should be_within(0.01).of(expected_b) }
  end

end
