# balance_sheet_calculation_spec.rb

require 'spec_helper'

describe FinModeling::BalanceSheetCalculation  do
  before(:all) do
    google_2011_annual_rpt = "http://www.sec.gov/Archives/edgar/data/1288776/000119312512025336/0001193125-12-025336-index.htm"
    filing = FinModeling::AnnualReportFiling.download google_2011_annual_rpt
    @balance_sheet = filing.balance_sheet
    @period = @balance_sheet.periods.last
  end

  describe ".assets_calculation" do
    subject { @balance_sheet.assets_calculation }
    it { should be_a FinModeling::AssetsCalculation }
    its(:label) { should match /asset/i }

    let(:right_side_sum) { @balance_sheet.liabs_and_equity_calculation.leaf_items_sum(:period=>@period) }
    specify { subject.leaf_items_sum(:period=>@period).should be_within(1.0).of(right_side_sum) }
  end

  describe ".liabs_and_equity_calculation" do
    subject { @balance_sheet.liabs_and_equity_calculation}
    it { should be_a FinModeling::LiabsAndEquityCalculation }
    its(:label) { should match /liab.*equity/i }
  end

  describe ".is_valid?" do
    context "if none of the asset leaf nodes contains the term 'cash'" do
      it "returns false" do
        #ea_2011_annual_rpt = "http://www.sec.gov/Archives/edgar/data/712515/000119312511149262/0001193125-11-149262-index.htm"
        #filing = FinModeling::AnnualReportFiling.download ea_2011_annual_rpt
        #filing.balance_sheet.is_valid?.should be_false
        pending "Need to find another example of this...."
      end
    end
    context "if none of the liability/equity net income leaf nodes contains the term 'equity'" do
      it "returns false" do
        #ea_2011_annual_rpt = "http://www.sec.gov/Archives/edgar/data/712515/000119312511149262/0001193125-11-149262-index.htm"
        #filing = FinModeling::AnnualReportFiling.download ea_2011_annual_rpt
        #filing.balance_sheet.is_valid?.should be_false
        pending "Need to find another example of this...."
      end
    end
    context "if the assets total does not match the liabilities and equity total" do
      it "returns false" do
        #ea_2011_annual_rpt = "http://www.sec.gov/Archives/edgar/data/712515/000119312511149262/0001193125-11-149262-index.htm"
        #filing = FinModeling::AnnualReportFiling.download ea_2011_annual_rpt
        #filing.balance_sheet.is_valid?.should be_false
        pending "Need to find another example of this...."
      end
    end
    context "otherwise" do
      it "returns true" do
        @balance_sheet.is_valid?.should be_true
      end
    end
  end

  describe ".reformulated" do
    subject { @balance_sheet.reformulated(@period) }
    it { should be_a FinModeling::ReformulatedBalanceSheet }
  end

  describe ".write_constructor" do
    before(:all) do
      file_name = "/tmp/finmodeling-bal-sheet.rb"
      item_name = "@bal_sheet"
      file = File.open(file_name, "w")
      @balance_sheet.write_constructor(file, item_name)
      file.close

      eval(File.read(file_name))
      @loaded_bs = eval(item_name)
    end

    context "after write_constructor()ing it to a file and then eval()ing the results" do
      subject { @loaded_bs }
      it { should have_the_same_periods_as @balance_sheet }
      it { should have_the_same_reformulated_last_total(:net_operating_assets).as(@balance_sheet) }
    end
  end

end

