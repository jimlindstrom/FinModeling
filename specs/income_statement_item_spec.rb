# period_array_spec.rb

require 'spec_helper'

describe FinModeling::IncomeStatementItem do

  before(:all) do
    #FinModeling::IncomeStatementItem.load_vectors_and_train(FinModeling::ISI_TRAINING_VECTORS)
  end

  describe "new" do
    it "takes a string and returns a new IncomeStatementItem" do
      isi = FinModeling::IncomeStatementItem.new("Cost of Goods Sold")
      isi.should be_an_instance_of FinModeling::IncomeStatementItem
    end
  end

  describe "train" do
    it "trains the classifier that this ISI is of the given type" do
      FinModeling::IncomeStatementItem.new("provision for income tax").train(:tax)
    end
  end

  describe "classification_estimates" do
    it "returns a hash with the confidence in each ISI type" do
      isi = FinModeling::IncomeStatementItem.new("Cost of Services")

      FinModeling::IncomeStatementItem::ISI_TYPES.each do |isi_type|
        isi.classification_estimates.keys.include?(isi_type).should be_true
      end
    end
  end

  describe "classify" do
    it "returns the ISI type with the highest probability estimate" do
      isi = FinModeling::IncomeStatementItem.new("provision for income tax")
      estimates = isi.classification_estimates
      estimates[isi.classify].should be_within(0.1).of(estimates.values.max)
    end
  end

  describe "load_vectors_and_train" do
    # the before(:all) clause calls load_vectors_and_train already
    # we can just focus, here, on its effects

    it "loads vectors from a given file, trains on each example, and correctly classifies tax" do
      isi = FinModeling::IncomeStatementItem.new("provision for income tax")
      isi.classify.should == :tax
    end

    it "loads vectors from a given file, trains on each example, and correctly classifies revenue" do
      isi = FinModeling::IncomeStatementItem.new("software licensing revenues net")
      isi.classify.should == :or
    end

    it "classifies >95% correctly" do
      num_items = 0
      errors = []
      FinModeling::ISI_TRAINING_VECTORS.each do |vector|
        num_items += 1
        isi = FinModeling::IncomeStatementItem.new(vector[:item_string])
        if isi.classify != vector[:isi_type]
          errors.push({ :isi=>isi.to_s, :expected=>vector[:isi_type], :got=>isi.classify })
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
    it "returns an array of downcased 1-word, 2-word, and 3-word tokens" do
      isi = FinModeling::IncomeStatementItem.new("Cost of Goods Sold")
      expected_tokens  = ["^", "cost", "of", "goods", "sold", "$"]
      expected_tokens += ["^ cost", "cost of", "of goods", "goods sold", "sold $"]
      expected_tokens += ["^ cost of", "cost of goods", "of goods sold", "goods sold $"]
      isi.tokenize.sort.should == expected_tokens.sort
    end
  end

end
