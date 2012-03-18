# period_array_spec.rb

require 'spec_helper'

describe FinModeling::AssetsItem do

  before(:all) do
    #FinModeling::AssetsItem.load_vectors_and_train(FinModeling::AssetsItem::TRAINING_VECTORS)
  end

  describe "new" do
    it "takes a string and returns a new AssetsItem" do
      ai = FinModeling::AssetsItem.new("Property Plant And Equipment Net")
      ai.should be_an_instance_of FinModeling::AssetsItem
    end
  end

  describe "train" do
    it "trains the classifier that this AssetsItem is of the given type" do
      FinModeling::AssetsItem.new("Property Plant and Equipment Net").train(:oa)
    end
  end

  describe "classification_estimates" do
    it "returns a hash with the confidence in each AssetsItem type" do
      ai = FinModeling::AssetsItem.new("Property Plant And Equipment Net")

      FinModeling::AssetsItem::TYPES.each do |klass|
        ai.classification_estimates.keys.include?(klass).should be_true
      end
    end
  end

  describe "classify" do
    it "returns the AssetsItem type with the highest probability estimate" do
      ai = FinModeling::AssetsItem.new("Property Plant And Equipment Net")
      estimates = ai.classification_estimates
      estimates[ai.classify].should be_within(0.1).of(estimates.values.max)
    end
  end

  describe "load_vectors_and_train" do
    # the before(:all) clause calls load_vectors_and_train already
    # we can just focus, here, on its effects

    it "classifies >95% correctly" do
      num_items = 0
      errors = []
      FinModeling::AssetsItem::TRAINING_VECTORS.each do |vector|
        num_items += 1
        ai = FinModeling::AssetsItem.new(vector[:item_string])
        if ai.classify != vector[:klass]
          errors.push({ :ai=>ai.to_s, :expected=>vector[:klass], :got=>ai.classify })
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
