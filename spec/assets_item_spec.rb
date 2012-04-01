# period_array_spec.rb

require 'spec_helper'

describe FinModeling::AssetsItem do

  before(:all) do
    #FinModeling::AssetsItem.load_vectors_and_train(FinModeling::AssetsItem::TRAINING_VECTORS)
  end

  describe "new" do
    subject { FinModeling::AssetsItem.new("Property Plant And Equipment Net") }
    it { should be_a FinModeling::AssetsItem }
  end

  describe "train" do
    subject { FinModeling::AssetsItem.new("Property Plant And Equipment Net") }
    it "trains the classifier that this AssetsItem is of the given type" do
      subject.train(:oa)
    end
  end

  describe "classification_estimates" do
    subject { FinModeling::AssetsItem.new("Property Plant And Equipment Net").classification_estimates }
    its(:keys) { should == FinModeling::AssetsItem::TYPES }
  end

  describe "classify" do
    let(:ai) { FinModeling::AssetsItem.new("Property Plant And Equipment Net") }
    subject { ai.classify }
    it "returns the AssetsItem type with the highest probability estimate" do
      estimates = ai.classification_estimates
      estimates[subject].should be_within(0.1).of(estimates.values.max)
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
