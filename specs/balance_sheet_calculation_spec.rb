# balance_sheet_calculation_spec.rb

require 'spec_helper'

describe FinModeling::BalanceSheetCalculation  do
  before(:all) do
    google_2011_annual_rpt = "http://www.sec.gov/Archives/edgar/data/1288776/000119312512025336/0001193125-12-025336-index.htm"
    filing = FinModeling::AnnualReportFiling.download google_2011_annual_rpt
    @balance_sheet = filing.balance_sheet
  end

  describe "assets" do
    it "returns the root node of the assets calculation" do
      @balance_sheet.assets.label.downcase.should match /asset/
    end
  end

  describe "liabs_and_equity" do
    it "returns the root node of the liability & shareholders' equity calculation" do
      @balance_sheet.liabs_and_equity.label.downcase.should match /liab.*equity/
    end
  end
end

