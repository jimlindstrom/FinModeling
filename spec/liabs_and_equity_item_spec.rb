# period_array_spec.rb

require 'spec_helper'

describe FinModeling::LiabsAndEquityItem do

  describe ".new" do
    subject { FinModeling::LiabsAndEquityItem.new("Accounts Payable Current") }
    it { should be_a FinModeling::LiabsAndEquityItem }
  end

  describe ".train" do
    it "trains the classifier that this LiabsAndEquityItem is of the given type" do
      FinModeling::LiabsAndEquityItem.new("Accounts Payable Current").train(:ol)
    end
  end

  describe ".classification_estimates" do
    subject { FinModeling::LiabsAndEquityItem.new("Accounts Payable Current").classification_estimates }

    it { should be_a Hash }
    specify { subject.keys.sort == FinModeling::LiabsAndEquityItem::TYPES.sort }
  end

  describe ".classify" do
    let(:laei) { FinModeling::LiabsAndEquityItem.new("Accounts Payable Current") }
    subject { laei.classify }
    it "returns the LiabsAndEquityItem type with the highest probability estimate" do
      estimates = laei.classification_estimates
      estimates[subject].should be_within(0.1).of(estimates.values.max)
    end
  end

  describe ".load_vectors_and_train" do
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
