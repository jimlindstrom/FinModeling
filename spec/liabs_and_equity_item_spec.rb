# period_array_spec.rb

require 'spec_helper'

describe FinModeling::LiabsAndEquityItem do

  before(:all) do
    #FinModeling::LiabsAndEquityItem.load_vectors_and_train(FinModeling::LiabsAndEquityItem::TRAINING_VECTORS)
  end

  describe "new" do
    it "takes a string and returns a new LiabsAndEquityItem" do
      laei = FinModeling::LiabsAndEquityItem.new("Accounts Payable Current")
      laei.should be_an_instance_of FinModeling::LiabsAndEquityItem
    end
  end

  describe "train" do
    it "trains the classifier that this LiabsAndEquityItem is of the given type" do
      FinModeling::LiabsAndEquityItem.new("Accounts Payable Current").train(:ol)
    end
  end

  describe "classification_estimates" do
    it "returns a hash with the confidence in each LiabsAndEquityItem type" do
      laei = FinModeling::LiabsAndEquityItem.new("Accounts Payable Current")

      FinModeling::LiabsAndEquityItem::TYPES.each do |klass|
        laei.classification_estimates.keys.include?(klass).should be_true
      end
    end
  end

  describe "classify" do
    it "returns the LiabsAndEquityItem type with the highest probability estimate" do
      laei = FinModeling::LiabsAndEquityItem.new("Accounts Payable Current")
      estimates = laei.classification_estimates
      estimates[laei.classify].should be_within(0.1).of(estimates.values.max)
    end
  end

  describe "load_vectors_and_train" do
    # the before(:all) clause calls load_vectors_and_train already
    # we can just focus, here, on its effects

    it "classifies >95% correctly" do
      num_items = 0
      errors = []
      FinModeling::LiabsAndEquityItem::TRAINING_VECTORS.each do |vector|
        num_items += 1
        laei = FinModeling::LiabsAndEquityItem.new(vector[:item_string])
        if laei.classify != vector[:klass]
          errors.push({ :laei=>laei.to_s, :expected=>vector[:klass], :got=>laei.classify })
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
