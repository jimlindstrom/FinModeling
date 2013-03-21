require 'spec_helper'

describe FinModeling::ComprehensiveIncomeStatementItem do

  describe "new" do
    subject { FinModeling::ComprehensiveIncomeStatementItem.new("Comprehensive Income Net Of Tax Attributable To Noncontrolling Interest") }
    it { should be_a FinModeling::ComprehensiveIncomeStatementItem }
  end

  describe "train" do
    let(:item) { FinModeling::ComprehensiveIncomeStatementItem.new("Comprehensive Income Net Of Tax Attributable To Noncontrolling Interest") }
    it "trains the classifier that this ComprehensiveIncomeStatementItem is of the given type" do
      item.train(:ooci_nci)
    end
  end

  describe "classification_estimates" do
    let(:item) { FinModeling::ComprehensiveIncomeStatementItem.new("Comprehensive Income Net Of Tax Attributable To Noncontrolling Interest") }
    subject { item.classification_estimates }
    its(:keys) { should == FinModeling::ComprehensiveIncomeStatementItem::TYPES }
  end

  describe "classify" do
    let(:cisi) { FinModeling::ComprehensiveIncomeStatementItem.new("Comprehensive Income Net Of Tax Attributable To Noncontrolling Interest") }
    subject { cisi.classify }
    it "returns the ComprehensiveIncomeStatementItem type with the highest probability estimate" do
      estimates = cisi.classification_estimates
      estimates[subject].should be_within(0.1).of(estimates.values.max)
    end
  end

  describe "load_vectors_and_train" do
    # the before(:all) clause calls load_vectors_and_train already
    # we can just focus, here, on its effects

    it "classifies >95% correctly" do # FIXME: add more vectors to tighten this up 
      num_items = 0
      errors = []
      FinModeling::ComprehensiveIncomeStatementItem::TRAINING_VECTORS.each do |vector|
        num_items += 1
        cisi = FinModeling::ComprehensiveIncomeStatementItem.new(vector[:item_string])
        if cisi.classify != vector[:klass]
          errors.push({ :cisi=>cisi.to_s, :expected=>vector[:klass], :got=>cisi.classify })
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
