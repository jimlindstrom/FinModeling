# period_array_spec.rb

require 'spec_helper'

describe FinModeling::CashChangeItem do

  describe "new" do
    subject { FinModeling::CashChangeItem.new("Depreciation and amortization of property and equipment") }
    it { should be_a FinModeling::CashChangeItem }
  end

  describe "train" do
    let(:item) { FinModeling::CashChangeItem.new("Depreciation and amortization of property and equipment") }
    it "trains the classifier that this CashChangeItem is of the given type" do
      item.train(:c)
    end
  end

  describe "classification_estimates" do
    let(:item) { FinModeling::CashChangeItem.new("Depreciation and amortization of property and equipment") }
    subject { item.classification_estimates }
    its(:keys) { should == FinModeling::CashChangeItem::TYPES }
  end

  describe "classify" do
    let(:cci) { FinModeling::CashChangeItem.new("Depreciation and amortization of property and equipment") }
    subject { cci.classify }
    it "returns the CashChangeItem type with the highest probability estimate" do
      estimates = cci.classification_estimates
      estimates[subject].should be_within(0.1).of(estimates.values.max)
    end
  end

  describe "load_vectors_and_train" do
    # the before(:all) clause calls load_vectors_and_train already
    # we can just focus, here, on its effects

    it "classifies >92% correctly" do # FIXME: add more vectors to tighten this up 
      num_items = 0
      errors = []
      FinModeling::CashChangeItem::TRAINING_VECTORS.each do |vector|
        num_items += 1
        cci = FinModeling::CashChangeItem.new(vector[:item_string])
        if cci.classify != vector[:klass]
          errors.push({ :cci=>cci.to_s, :expected=>vector[:klass], :got=>cci.classify })
        end
      end

      pct_errors = errors.length.to_f / num_items
      if pct_errors > 0.08
        puts "errors: " + errors.inspect
      end
      pct_errors.should be < 0.08

    end
  end

end
