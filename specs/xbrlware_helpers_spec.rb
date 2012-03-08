# string_helpers_spec.rb

require 'spec_helper'

describe Xbrlware::Item do

  describe "default_balance_defn" do
    it "returns either \"credit\" or \"debit\"" do
      item = Xbrlware::Item.new(instance=nil, name="Property Plant and Equipment Net", context=nil, value="123456.0")
      [:credit, :debit].include?(item.default_balance_defn).should == true
    end

    it "classifies >95% correctly" do
      num_items = 0
      errors = []
      FinModeling::XbrlwareItem::TRAINING_VECTORS.each do |vector|
        num_items += 1
        item = Xbrlware::Item.new(instance=nil, name=vector[:item_string], context=nil, value="123456.0")
        if item.default_balance_defn != vector[:balance_defn]
          errors.push({ :item=>item.to_s, :expected=>vector[:balance_defn], :got=>item.default_balance_defn.to_s })
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
