# string_helpers_spec.rb

require 'spec_helper'

describe Xbrlware::Context::Period do
  describe ".days" do
    context "when a date range" do
      let(:value) { {"start_date"=>Date.parse("2011-01-01"), "end_date"=>Date.parse("2011-03-31")} }
      subject { Xbrlware::Context::Period.new(value).days }

      it { should be_a Fixnum }
      it { should == Xbrlware::DateUtil.days_between(value["end_date"], value["start_date"]) }
    end
  end
  describe ".plus_n_months" do
    context "when an instantaneous date" do
      let(:old_value) { Date.parse("2010-12-31") }
      let(:old) { old = Xbrlware::Context::Period.new(old_value) }

      subject { old.plus_n_months(3) }

      it { should be_a Xbrlware::Context::Period }
      its(:to_pretty_s) { should == "2011-03-28" }
    end
    context "when a date range" do
      let(:old_value) { {"start_date"=>Date.parse("2011-01-01"), "end_date"=>Date.parse("2011-03-31")} }
      let(:old) { old = Xbrlware::Context::Period.new(old_value) }

      subject { old.plus_n_months(3) }

      it { should be_a Xbrlware::Context::Period }
      its(:to_pretty_s) { should == "2011-04-01 to 2011-06-30" }
    end
  end
end

describe Xbrlware::Context do

  describe "write_constructor" do
    context "when the period is nil" do
      before(:all) do
        file_name = "/tmp/finmodeling-context1.rb"
        item_name = "@item_context"
        file = File.open(file_name, "w")
        @orig_item = FinModeling::Factory.Context()
        @orig_item.write_constructor(file, item_name)
        file.close
  
        eval(File.read(file_name))
  
        @loaded_item = eval(item_name)
      end
  
      it "writes itself to a file, and when reloaded, has the same period" do
        @loaded_item.period.value.should == @orig_item.period.value
      end
    end

    context "when the period is an instant" do
      before(:all) do
        file_name = "/tmp/finmodeling-context2.rb"
        item_name = "@item_context"
        file = File.open(file_name, "w")
        @orig_item = FinModeling::Factory.Context(:period => Date.parse("2010-01-01"))
        @orig_item.write_constructor(file, item_name)
        file.close
  
        eval(File.read(file_name))
  
        @loaded_item = eval(item_name)
      end
  
      it "writes itself to a file, and when reloaded, has the same period" do
        @loaded_item.period.to_pretty_s.should == @orig_item.period.to_pretty_s
      end
    end

    context "when the period is a duration" do
      before(:all) do
        file_name = "/tmp/finmodeling-context3.rb"
        item_name = "@item_context"
        file = File.open(file_name, "w")
        @orig_item = FinModeling::Factory.Context(:period => {"start_date" => Date.parse("2010-01-01"),
                                                              "end_date"   => Date.parse("2011-01-01")})
        @orig_item.write_constructor(file, item_name)
        file.close
  
        eval(File.read(file_name))
  
        @loaded_item = eval(item_name)
      end
  
      it "writes itself to a file, and when reloaded, has the same period" do
        @loaded_item.period.to_pretty_s.should == @orig_item.period.to_pretty_s
      end
    end
  end

end

#describe Xbrlware::ValueMappingWithClassifier do
#
#  describe "default_balance_defn" do
#    it "returns either \"credit\" or \"debit\"" do
#      item = Xbrlware::Item.new(instance=nil, name="Property Plant and Equipment Net", context=nil, value="123456.0")
#      [:credit, :debit].include?(item.default_balance_defn).should == true
#    end
#
#    it "classifies >95% correctly" do
#      num_items = 0
#      errors = []
#      Xbrlwarem::ValueMapping::TRAINING_VECTORS.each do |vector|
#        num_items += 1
#        item = Xbrlware::Item.new(instance=nil, name=vector[:item_string], context=nil, value="123456.0")
#        if item.default_balance_defn != vector[:balance_defn]
#          errors.push({ :item=>item.to_s, :expected=>vector[:balance_defn], :got=>item.default_balance_defn.to_s })
#        end
#      end
#
#      pct_errors = errors.length.to_f / num_items
#      if pct_errors > 0.05
#        puts "errors: " + errors.inspect
#      end
#      pct_errors.should be < 0.05
#
#    end
#  end
#
#  describe "write_constructor" do
#    before(:all) do
#      file_name = "/tmp/finmodeling-item.rb"
#      item_name = "@item"
#      file = File.open(file_name, "w")
#      @orig_item = Xbrlware::Item.new(instance=nil, 
#                                      name="Property Plant and Equipment Net", 
#                                      context=FinModeling::Factory.Context(:period => Date.parse("2010-01-01")), 
#                                      value="123456.0",
#                                      unit=nil,
#                                      precision=nil,
#                                      decimals="-3",
#                                      footnotes=nil)
#      @orig_item.write_constructor(file, item_name)
#      file.close
#
#      eval(File.read(file_name))
#
#      @loaded_item = eval(item_name)
#    end
#
#    it "writes itself to a file, and when reloaded, has the same name" do
#      @loaded_item.name.should == @orig_item.name
#    end
#    it "writes itself to a file, and when reloaded, has the same value" do
#      @loaded_item.value().should == @orig_item.value()
#    end
#    it "writes itself to a file, and when reloaded, has the same decimals" do
#      @loaded_item.decimals.should == @orig_item.decimals
#    end
#    it "writes itself to a file, and when reloaded, has the same context period" do
#      @loaded_item.context.period.to_pretty_s.should == @orig_item.context.period.to_pretty_s
#    end
#  end
#
#end

describe Xbrlware::Linkbase::CalculationLinkbase::Calculation::CalculationArc do
  describe "write_constructor" do
    before(:all) do
      google_2011_annual_rpt = "http://www.sec.gov/Archives/edgar/data/1288776/000119312512025336/0001193125-12-025336-index.htm"
      filing = FinModeling::AnnualReportFiling.download google_2011_annual_rpt
      @orig_item = filing.income_statement.calculation.arcs[0]

      file_name = "/tmp/finmodeling-calc-arc.rb"
      item_name = "@item"
      file = File.open(file_name, "w")
      @orig_item.write_constructor(file, item_name)
      file.close

      eval(File.read(file_name))
      @loaded_item = eval(item_name)
    end

    it "writes itself to a file, and when reloaded, has the same item_id" do
      @loaded_item.item_id.should == @orig_item.item_id
    end
    it "writes itself to a file, and when reloaded, has the same label" do
      @loaded_item.label.should == @orig_item.label
    end
    it "writes itself to a file, and when reloaded, has the same number of children" do
      @loaded_item.children.length.should == @orig_item.children.length
    end
    it "writes itself to a file, and when reloaded, has the same number of items" do
      @loaded_item.items.length.should == @orig_item.items.length
    end
  end
end

