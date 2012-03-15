# company_filing_calculation_spec.rb

require 'spec_helper'

describe FinModeling::CalculationSummary do
  before(:all) do
    if RSpec.configuration.use_balance_sheet_factory?
      @bal_sheet = FinModeling::Factory.BalanceSheetCalculation(:sheet => 'google 10-k 2011-12-31 balance sheet')
    else
      google_2011_annual_rpt = "http://www.sec.gov/Archives/edgar/data/1288776/000119312512025336/0001193125-12-025336-index.htm"
      filing = FinModeling::AnnualReportFiling.download google_2011_annual_rpt
      @bal_sheet = filing.balance_sheet
    end
    @period = @bal_sheet.periods.last
    @a = @bal_sheet.assets_calculation
    @calc_summary = @a.summary(@period)
  end

  describe "total" do
    before(:all) do
      @raw_total = @calc_summary.rows.map{ |row| row.val }.inject(:+)
    end
    it "should return a floating point total of all values" do
      @calc_summary.total.should be_within(0.1).of(@raw_total)
    end
  end

  describe "filter_by_type" do
    it "should return a new FinModeling::CalculationSummary" do
      @calc_summary.filter_by_type(:oa).should be_an_instance_of FinModeling::CalculationSummary
    end
    it "should return a summary of only the requested type" do
      @calc_summary.filter_by_type(:oa).rows.map{ |row| row.type }.uniq.should == [:oa]
    end
  end

  describe "+" do
    before(:each) do
      @cs1 = FinModeling::CalculationSummary.new
      @cs1.title = "CS 1"
      @cs1.rows = [ FinModeling::CalculationSummaryRow.new(:key => "First  Row", :val => 1),
                    FinModeling::CalculationSummaryRow.new(:key => "Second Row", :val => 2) ]
      
      @cs2 = FinModeling::CalculationSummary.new
      @cs2.title = "CS 1"
      @cs2.rows = [ FinModeling::CalculationSummaryRow.new(:key => "First  Row", :val => 1),
                    FinModeling::CalculationSummaryRow.new(:key => "Second Row", :val => 2) ]
    end
    it "should return a MultiColumnCalculationSummary" do
      (@cs1 + @cs2).should be_an_instance_of FinModeling::MultiColumnCalculationSummary
    end
    it "should set the title to the first summary's title" do
      cs3 = (@cs1 + @cs2)
      cs3.title.should == @cs1.title
    end
    it "should set the row labels to the first summary's row labels" do
      cs3 = (@cs1 + @cs2)
      cs3.rows.map{ |row| row.key }.should == @cs1.rows.map{ |row| row.key }
    end
    it "should merge the values of summary into an array of values in the result" do
      cs3 = (@cs1 + @cs2)
      0.upto(1).each do |row_idx|
        cs3.rows[row_idx].vals.should == [ @cs1.rows[row_idx].val, @cs2.rows[row_idx].val ] 
      end
    end
  end
end
