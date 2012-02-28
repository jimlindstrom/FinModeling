# company_filing_calculation_spec.rb

require 'spec_helper'

describe FinModeling::CompanyFilingCalculation  do
  before(:all) do
    google_2011_annual_rpt = "http://www.sec.gov/Archives/edgar/data/1288776/000119312512025336/0001193125-12-025336-index.htm"
    @filing = FinModeling::AnnualReportFiling.download google_2011_annual_rpt

    vepc_2010_annual_rpt = "http://www.sec.gov/Archives/edgar/data/103682/000119312511049905/d10k.htm"
    @filing_with_mixed_order = FinModeling::AnnualReportFiling.download vepc_2010_annual_rpt
  end

  describe "new" do
    before(:each) do
      @taxonomy = nil
      @calculation = FinModeling::Mocks::Calculation.new
    end
    it "takes a taxonomy and a xbrlware calculation and returns a CompanyFilingCalculation" do
      FinModeling::CompanyFilingCalculation.new(@taxonomy, @calculation).should be_an_instance_of FinModeling::CompanyFilingCalculation
    end
  end

  describe "label" do
    before(:each) do
      @taxonomy = nil
      @calculation = FinModeling::Mocks::Calculation.new
    end
    it "returns the calculation's label" do
      cfc = FinModeling::CompanyFilingCalculation.new(@taxonomy, @calculation)
      cfc.label.should == @calculation.label
    end
  end

  describe "periods" do
    before(:all) do
      @balance_sheet = @filing.balance_sheet
    end
    it "returns an array of the periods over/at which this calculation can be queried" do
      @balance_sheet.periods.map{|x| x.to_s }.sort.should == ["2008-12-31", "2009-12-31", "2010-12-31", "2011-12-31"]
    end
  end

  describe "leaf_items" do
    before(:all) do
      balance_sheet = @filing.balance_sheet
      @assets = balance_sheet.assets_calculation
      @period = balance_sheet.periods.last
    end
    it "returns an array of the leaf items in the calculation tree that match the period" do
      @assets.leaf_items(@period).length.should == 12
    end
    it "returns an array of the leaf items in the calculation tree that match the period" do
      @assets.leaf_items(@period).first.should be_an_instance_of Xbrlware::Item
    end
    it "returns all leaf items, if no period given" do
      @assets.leaf_items.length.should == 26
    end
  end

  describe "leaf_items_sum" do
    before(:all) do
      # this balance sheet has some items (accumulated depreciation) that 
      # should be subtracted from total assets, which makes it a better test
      # than the google annual report
      balance_sheet = @filing_with_mixed_order.balance_sheet
      @assets = balance_sheet.assets_calculation
      @period = balance_sheet.periods.last
    end
    it "returns the sum of the calculation tree, in the given period" do
      @assets.leaf_items_sum(@period).should be_within(1.0).of(42817000000.0)
    end
  end
end
