# company_filing_calculation_spec.rb

require 'spec_helper'

describe FinModeling::CompanyFilingCalculation  do
  before(:all) do
    google_2011_annual_rpt = "http://www.sec.gov/Archives/edgar/data/1288776/000119312512025336/0001193125-12-025336-index.htm"
    @filing = FinModeling::AnnualReportFiling.download google_2011_annual_rpt
  end

  let(:calculation) { FinModeling::Mocks::Calculation.new }
  subject { FinModeling::CompanyFilingCalculation.new(calculation) }

  it { should be_a FinModeling::CompanyFilingCalculation }
  its(:label) { should == calculation.label }

  describe "periods" do
    subject { @filing.balance_sheet.periods }
    it { should be_a FinModeling::PeriodArray }
    specify { subject.map{ |x| x.to_s }.sort.should == ["2008-12-31", "2009-12-31", "2010-12-31", "2011-12-31"] }
  end

  describe "leaf_items" do
    let(:assets) { @filing.balance_sheet.assets_calculation }
    context "when given a period" do
      subject { assets.leaf_items(:period => @filing.balance_sheet.periods.last) } 
      it "should contain Xbrlware::Item's" do
        subject.all?{ |x| x.class == Xbrlware::Item }.should be_true
      end
      it "returns the leaf items that match the period" do
        subject.should have(12).items
      end
    end
    context "when not given a period" do
      subject { assets.leaf_items }
      it "should contain Xbrlware::Item's" do
        subject.all?{ |x| x.class == Xbrlware::Item }.should be_true
      end
      it "returns all leaf items" do
        subject.should have(26).items
      end
    end
  end

  describe "leaf_items_sum" do
    context "given a balance sheet with items that subtract from the total (like accum. depreciation)" do
      it "returns the sum of the calculation tree, in the given period" do
        pending "can't parse this 10-k. need to find another suitable example"

        vepc_2010_annual_rpt = "http://www.sec.gov/Archives/edgar/data/103682/000119312511049905/d10k.htm"
        @filing_with_mixed_order = FinModeling::AnnualReportFiling.download vepc_2010_annual_rpt
  
        balance_sheet = @filing_with_mixed_order.balance_sheet
        @assets = balance_sheet.assets_calculation
        @period = balance_sheet.periods.last
  
        mapping = Xbrlware::ValueMapping.new
        mapping.policy[:credit] = :flip
  
        @assets.leaf_items_sum(:period=>@period, :mapping=>mapping).should be_within(1.0).of(42817000000.0)
      end
    end
  end
end
