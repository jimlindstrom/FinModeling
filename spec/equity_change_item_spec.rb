# equity_change_item_spec.rb

require 'spec_helper'

describe FinModeling::EquityChangeItem do

  describe "new" do
    subject { FinModeling::EquityChangeItem.new("Depreciation and amortization of property and equipment") }
    it { should be_a FinModeling::EquityChangeItem }
  end

  describe "train" do
    let(:item) { FinModeling::EquityChangeItem.new("Depreciation and amortization of property and equipment") }
    it "trains the classifier that this EquityChangeItem is of the given type" do
      item.train(:oci)
    end
  end

  describe "classification_estimates" do
    let(:item) { FinModeling::EquityChangeItem.new("Depreciation and amortization of property and equipment") }
    subject { item.classification_estimates }
    its(:keys) { should == FinModeling::EquityChangeItem::TYPES }
  end

  describe "classify" do
    let(:eci) { FinModeling::EquityChangeItem.new("Depreciation and amortization of property and equipment") }
    subject { eci.classify }
    it "returns the EquityChangeItem type with the highest probability estimate" do
      estimates = eci.classification_estimates
      estimates[subject].should be_within(0.1).of(estimates.values.max)
    end
  end

  describe "load_vectors_and_train" do
    # the before(:all) clause calls load_vectors_and_train already
    # we can just focus, here, on its effects

    it "classifies >95% correctly" do # FIXME: add more vectors to tighten this up 
      num_items = 0
      errors = []
      FinModeling::EquityChangeItem::TRAINING_VECTORS.each do |vector|
        num_items += 1
        eci = FinModeling::EquityChangeItem.new(vector[:item_string])
        if eci.classify != vector[:klass]
          errors.push({ :eci=>eci.to_s, :expected=>vector[:klass], :got=>eci.classify })
        end
      end

      pct_errors = errors.length.to_f / num_items
      if pct_errors > 0.05
        puts "errors: " + errors.inspect
      end
      pct_errors.should be < 0.05

    end
  end

end
