require 'spec_helper'

describe FinModeling::DebtCostOfCapital do
  describe "#calculate" do
    context "if given the after tax cost" do
      let(:r) { FinModeling::Rate.new(0.05) }
      subject { FinModeling::DebtCostOfCapital.calculate(:after_tax_cost => r) }
      it { should be_a FinModeling::Rate }
      its(:value) { should be_within(0.1).of(r.value) }
    end
    context "if given the after tax cost and marginal tax rate" do
      let(:r) { FinModeling::Rate.new(0.05) }
      let(:t) { FinModeling::Rate.new(0.35) }
      subject { FinModeling::DebtCostOfCapital.calculate(:before_tax_cost => r, :marginal_tax_rate => t) }
      it { should be_a FinModeling::Rate }
      its(:value) { should be_within(0.1).of(r.value * (1.0 - t.value)) }
    end
  end
end
