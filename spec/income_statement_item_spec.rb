# period_array_spec.rb

require 'spec_helper'

describe FinModeling::IncomeStatementItem do
  let(:isi) { FinModeling::IncomeStatementItem.new("Cost of Goods Sold") }

  describe "new" do
    subject { isi }
    it { should be_a FinModeling::IncomeStatementItem }
  end

  describe "train" do
    it "trains the classifier that this ISI is of the given type" do
      isi.train(:tax)
    end
  end

  describe "classification_estimates" do
    subject { isi.classification_estimates }
    it { should be_a Hash }
    its(:keys) { should == FinModeling::IncomeStatementItem::TYPES }
  end

  describe "classify" do
    subject { isi.classify }
    it "returns the ISI type with the highest probability estimate" do
      estimates = isi.classification_estimates
      estimates[subject].should be_within(0.1).of(estimates.values.max)
    end
  end

  describe "load_vectors_and_train" do
    context "tax" do
      subject { FinModeling::IncomeStatementItem.new("provision for income tax").classify }
      it { should == :tax }
    end

    context "or" do
      subject { FinModeling::IncomeStatementItem.new("software licensing revenues net").classify }
      it { should == :or }
    end

    it "classifies >95% correctly" do
      num_items = 0
      errors = []
      FinModeling::IncomeStatementItem::TRAINING_VECTORS.each do |vector|
        num_items += 1
        isi = FinModeling::IncomeStatementItem.new(vector[:item_string])
        if isi.classify != vector[:klass]
          errors.push({ :isi=>isi.to_s, :expected=>vector[:klass], :got=>isi.classify })
        end
      end

      pct_errors = errors.length.to_f / num_items
      if pct_errors > 0.05
        puts "errors: " + errors.inspect
      end
      pct_errors.should be < 0.05

    end
  end

  describe "tokenize" do
    subject { FinModeling::IncomeStatementItem.new("Cost of Goods Sold").tokenize }
    it "returns an array of downcased 1-word, 2-word, and 3-word tokens" do
      expected_tokens  = ["^", "cost", "of", "goods", "sold", "$"]
      expected_tokens += ["^ cost", "cost of", "of goods", "goods sold", "sold $"]
      expected_tokens += ["^ cost of", "cost of goods", "of goods sold", "goods sold $"]
      subject.sort.should == expected_tokens.sort
    end
  end

end
