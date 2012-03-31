# balance_sheet_calculation_spec.rb

require 'spec_helper'

describe FinModeling::BalanceSheetCalculation  do
  before(:all) do
    google_2011_annual_rpt = "http://www.sec.gov/Archives/edgar/data/1288776/000119312512025336/0001193125-12-025336-index.htm"
    filing = FinModeling::AnnualReportFiling.download google_2011_annual_rpt
    @balance_sheet = filing.balance_sheet
    @period = @balance_sheet.periods.last
  end

  describe "assets_calculation" do
    it "returns an AssetsCalculation" do
      @balance_sheet.assets_calculation.should be_an_instance_of FinModeling::AssetsCalculation
    end
    it "returns the root node of the assets calculation" do
      @balance_sheet.assets_calculation.label.downcase.should match /asset/
    end
    it "sums to the same value as do the liabilities and equity" do
      left_sum = @balance_sheet.assets_calculation.leaf_items_sum(:period=>@period)
      right_sum = @balance_sheet.liabs_and_equity_calculation.leaf_items_sum(:period=>@period)
      left_sum.should be_within(1.0).of(right_sum)
    end
  end

  describe "liabs_and_equity_calculation" do
    it "returns a LiabsAndEquityCalculation" do
      @balance_sheet.liabs_and_equity_calculation.should be_an_instance_of FinModeling::LiabsAndEquityCalculation
    end
    it "returns the root node of the liability & shareholders' equity calculation" do
      @balance_sheet.liabs_and_equity_calculation.label.downcase.should match /liab.*equity/
    end
  end

  describe "is_valid?" do
    it "returns false if none of the asset leaf nodes contains the term 'cash'" do
      #ea_2011_annual_rpt = "http://www.sec.gov/Archives/edgar/data/712515/000119312511149262/0001193125-11-149262-index.htm"
      #filing = FinModeling::AnnualReportFiling.download ea_2011_annual_rpt
      #filing.balance_sheet.is_valid?.should be_false
      pending
    end
    it "returns false if none of the liability/equity net income leaf nodes contains the term 'equity'" do
      #ea_2011_annual_rpt = "http://www.sec.gov/Archives/edgar/data/712515/000119312511149262/0001193125-11-149262-index.htm"
      #filing = FinModeling::AnnualReportFiling.download ea_2011_annual_rpt
      #filing.balance_sheet.is_valid?.should be_false
      pending
    end
    it "returns false if the assets total does not match the liabilities and equity total" do
      #ea_2011_annual_rpt = "http://www.sec.gov/Archives/edgar/data/712515/000119312511149262/0001193125-11-149262-index.htm"
      #filing = FinModeling::AnnualReportFiling.download ea_2011_annual_rpt
      #filing.balance_sheet.is_valid?.should be_false
      pending
    end
    it "returns true otherwise" do
      @balance_sheet.is_valid?.should be_true
    end
  end

  describe "reformulated" do
    it "takes a period and returns a ReformulatedBalanceSheet" do
      @balance_sheet.reformulated(@period).should be_an_instance_of FinModeling::ReformulatedBalanceSheet
    end
  end

  describe "write_constructor" do
    before(:all) do
      file_name = "/tmp/finmodeling-bal-sheet.rb"
      item_name = "@bal_sheet"
      file = File.open(file_name, "w")
      @balance_sheet.write_constructor(file, item_name)
      file.close

      eval(File.read(file_name))

      @loaded_bs = eval(item_name)
    end

    it "writes itself to a file, and when reloaded, has the same periods" do
      expected_periods = @balance_sheet.periods.map{|x| x.to_pretty_s}.join(',')
      @loaded_bs.periods.map{|x| x.to_pretty_s}.join(',').should == expected_periods
    end
    it "writes itself to a file, and when reloaded, has the same net operating assets" do
      period = @balance_sheet.periods.last
      expected_noa = @balance_sheet.reformulated(period).net_operating_assets.total
      @loaded_bs.reformulated(period).net_operating_assets.total.should be_within(1.0).of(expected_noa)
    end
  end

end

