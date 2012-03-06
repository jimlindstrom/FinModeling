# period_array_spec.rb

require 'spec_helper'

describe FinModeling::PeriodArray  do

  describe "yearly" do
    before(:each) do
      dur_1yr = 1*60*60*24*365
      dur_3mo = dur_1yr / 4

      t_now = Time.new
      t_3mo_ago = t_now - dur_3mo
      t_1yr_ago = t_now - dur_1yr

      @arr = FinModeling::PeriodArray.new
      @arr.push Xbrlware::Context::Period.new({"start_date"=>t_1yr_ago, "end_date"=>t_3mo_ago})
      @arr.push Xbrlware::Context::Period.new({"start_date"=>t_3mo_ago, "end_date"=>t_now})
      @arr.push Xbrlware::Context::Period.new({"start_date"=>t_1yr_ago, "end_date"=>t_now})
    end
    it "returns a new PeriodArray" do
      @arr.yearly.should be_an_instance_of FinModeling::PeriodArray
    end
    it "returns only annual periods" do
      @arr.yearly.first.to_pretty_s.should == @arr[2].to_pretty_s
    end
  end

  describe "threequarterly" do
    before(:each) do
      dur_1yr = 1*60*60*24*365
      dur_3mo = dur_1yr / 4

      t_now = Time.new
      t_3mo_ago = t_now - dur_3mo
      t_6mo_ago = t_now - dur_3mo - dur_3mo
      t_1yr_ago = t_now - dur_1yr

      @arr = FinModeling::PeriodArray.new
      @arr.push Xbrlware::Context::Period.new({"start_date"=>t_1yr_ago, "end_date"=>t_3mo_ago})
      @arr.push Xbrlware::Context::Period.new({"start_date"=>t_3mo_ago, "end_date"=>t_now})
      @arr.push Xbrlware::Context::Period.new({"start_date"=>t_1yr_ago, "end_date"=>t_now})
    end
    it "returns a new PeriodArray" do
      @arr.yearly.should be_an_instance_of FinModeling::PeriodArray
    end
    it "returns only three-quarter periods" do
      @arr.yearly.first.to_pretty_s.should == @arr[0].to_pretty_s
    end
  end

  describe "halfyearly" do
    before(:each) do
      dur_1yr = 1*60*60*24*365
      dur_3mo = dur_1yr / 4

      t_now = Time.new
      t_3mo_ago = t_now - dur_3mo
      t_6mo_ago = t_now - dur_3mo - dur_3mo
      t_1yr_ago = t_now - dur_1yr

      @arr = FinModeling::PeriodArray.new
      @arr.push Xbrlware::Context::Period.new({"start_date"=>t_1yr_ago, "end_date"=>t_3mo_ago})
      @arr.push Xbrlware::Context::Period.new({"start_date"=>t_6mo_ago, "end_date"=>t_now})
      @arr.push Xbrlware::Context::Period.new({"start_date"=>t_1yr_ago, "end_date"=>t_now})
    end
    it "returns a new PeriodArray" do
      @arr.yearly.should be_an_instance_of FinModeling::PeriodArray
    end
    it "returns only two-quarter periods" do
      @arr.yearly.first.to_pretty_s.should == @arr[0].to_pretty_s
    end
  end

  describe "quarterly" do
    before(:each) do
      dur_1yr = 1*60*60*24*365
      dur_3mo = dur_1yr / 4

      t_now = Time.new
      t_3mo_ago = t_now - dur_3mo
      t_1yr_ago = t_now - dur_1yr

      @arr = FinModeling::PeriodArray.new
      @arr.push Xbrlware::Context::Period.new({"start_date"=>t_1yr_ago, "end_date"=>t_3mo_ago})
      @arr.push Xbrlware::Context::Period.new({"start_date"=>t_3mo_ago, "end_date"=>t_now})
      @arr.push Xbrlware::Context::Period.new({"start_date"=>t_1yr_ago, "end_date"=>t_now})
    end
    it "returns a new PeriodArray" do
      @arr.yearly.should be_an_instance_of FinModeling::PeriodArray
    end
    it "returns only quarterly periods" do
      @arr.yearly.first.to_pretty_s.should == @arr[1].to_pretty_s
    end
  end

end
