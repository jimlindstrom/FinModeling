# period_array_spec.rb

require 'spec_helper'

describe FinModeling::PeriodArray  do
  before(:all) do
    @t_now     = Date.parse('2012-01-01')
    @t_3mo_ago = Date.parse('2011-09-01')
    @t_6mo_ago = Date.parse('2011-06-01')
    @t_0mo_ago = Date.parse('2011-03-01')
    @t_1yr_ago = Date.parse('2011-01-01')

    @arr = FinModeling::PeriodArray.new
    @arr.push Xbrlware::Context::Period.new({"start_date"=>@t_1yr_ago, "end_date"=>@t_now})     # 1 yr
    @arr.push Xbrlware::Context::Period.new({"start_date"=>@t_1yr_ago, "end_date"=>@t_3mo_ago}) # 9 mo
    @arr.push Xbrlware::Context::Period.new({"start_date"=>@t_1yr_ago, "end_date"=>@t_6mo_ago}) # 6 mo
    @arr.push Xbrlware::Context::Period.new({"start_date"=>@t_3mo_ago, "end_date"=>@t_now})     # 3 mo
  end

  describe "yearly" do
    subject { @arr.yearly }
    it { should be_an_instance_of FinModeling::PeriodArray }
    it "returns only annual periods" do
      subject.first.to_pretty_s.should == @arr[0].to_pretty_s
    end
  end

  describe "threequarterly" do
    subject { @arr.threequarterly }
    it { should be_an_instance_of FinModeling::PeriodArray }
    it "returns only three-quarter periods" do
      subject.first.to_pretty_s.should == @arr[1].to_pretty_s
    end
  end

  describe "halfyearly" do
    subject { @arr.halfyearly }
    it { should be_an_instance_of FinModeling::PeriodArray }
    it "returns only two-quarter periods" do
      subject.first.to_pretty_s.should == @arr[2].to_pretty_s
    end
  end

  describe "quarterly" do
    subject { @arr.quarterly }
    it { should be_an_instance_of FinModeling::PeriodArray }
    it "returns only quarterly periods" do
      subject.first.to_pretty_s.should == @arr[3].to_pretty_s
    end
  end

end
