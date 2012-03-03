# company_filing_calculation_spec.rb

require 'spec_helper'

describe FinModeling::CalculationSummary do
  before(:all) do
    google_2011_annual_rpt = "http://www.sec.gov/Archives/edgar/data/1288776/000119312512025336/0001193125-12-025336-index.htm"
    filing = FinModeling::AnnualReportFiling.download google_2011_annual_rpt
    @bal_sheet = filing.balance_sheet
    @period = @bal_sheet.periods.last
    @a = @bal_sheet.assets_calculation
    @calc_summary = @a.summary(@period)
  end

  describe "total" do
    before(:all) do
      @raw_total = @calc_summary.rows.map{ |row| row[:val] }.inject(:+)
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
      @calc_summary.filter_by_type(:oa).rows.map{ |row| row[:type] }.uniq.should == [:oa]
    end
  end
end
