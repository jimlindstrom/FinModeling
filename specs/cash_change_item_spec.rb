# period_array_spec.rb

require 'spec_helper'

describe FinModeling::CashChangeItem do

  before(:all) do
    #FinModeling::CashChangeItem.load_vectors_and_train(FinModeling::CashChangeItem::TRAINING_VECTORS)
  end

  describe "new" do
    it "takes a string and returns a new CashChangeItem" do
      cci = FinModeling::CashChangeItem.new("Depreciation and amortization of property and equipment")
      cci.should be_an_instance_of FinModeling::CashChangeItem
    end
  end

  describe "train" do
    it "trains the classifier that this CashChangeItem is of the given type" do
      FinModeling::CashChangeItem.new("Depreciation and amortization of property and equipment").train(:c)
    end
  end

  describe "classification_estimates" do
    it "returns a hash with the confidence in each CashChangeItem type" do
      cci = FinModeling::CashChangeItem.new("Depreciation and amortization of property and equipment")

      FinModeling::CashChangeItem::TYPES.each do |klass|
        cci.classification_estimates.keys.include?(klass).should be_true
      end
    end
  end

  describe "classify" do
    it "returns the CashChangeItem type with the highest probability estimate" do
      cci = FinModeling::CashChangeItem.new("Depreciation and amortization of property and equipment")
      estimates = cci.classification_estimates
      estimates[cci.classify].should be_within(0.1).of(estimates.values.max)
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
