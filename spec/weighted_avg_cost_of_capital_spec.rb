require 'spec_helper'

describe FinModeling::WeightedAvgCostOfCapital do
  let(:equity_market_val)      { 2.2*1000*1000*1000 }
  let(:debt_market_val)        { 997.0*1000*1000 }
  let(:cost_of_equity)         { FinModeling::Rate.new(0.0087) }
  let(:after_tax_cost_of_debt) { FinModeling::Rate.new(0.0031) }

  describe '.new' do
    subject { FinModeling::WeightedAvgCostOfCapital.new(equity_market_val, debt_market_val, cost_of_equity, after_tax_cost_of_debt) }

    it { should be_a FinModeling::WeightedAvgCostOfCapital }
  end

  describe '.rate' do
    let(:wacc) { FinModeling::WeightedAvgCostOfCapital.new(equity_market_val, debt_market_val, cost_of_equity, after_tax_cost_of_debt) }
    subject { wacc.rate }

    let(:total_val) { equity_market_val + debt_market_val }
    let(:e_weight) { equity_market_val / total_val }
    let(:d_weight) { debt_market_val / total_val }
    let(:expected_wacc) { (e_weight * cost_of_equity.value) + (d_weight * after_tax_cost_of_debt.value) }
    its(:value) { should be_within(1.0).of(expected_wacc) }
  end

  describe '.summary' do
    let(:wacc) { FinModeling::WeightedAvgCostOfCapital.new(equity_market_val, debt_market_val, cost_of_equity, after_tax_cost_of_debt) }
    subject { wacc.summary }

    it { should be_a FinModeling::CalculationSummary }
  end
end
