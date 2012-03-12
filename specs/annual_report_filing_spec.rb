# annual_report_filing_spec.rb

require 'spec_helper'

describe FinModeling::AnnualReportFiling  do
  before (:all) do
    company = FinModeling::Company.new(FinModeling::Mocks::Entity.new)
    filing_url = company.annual_reports.last.link
    @filing = FinModeling::AnnualReportFiling.download(filing_url, caching=false)
  end

  describe "balance_sheet" do
    it "returns the balance sheet calculation" do
      @filing.balance_sheet.should be_an_instance_of FinModeling::BalanceSheetCalculation
    end
  end

  describe "income_statement" do
    it "returns the income statement calculation" do
      @filing.income_statement.should be_an_instance_of FinModeling::IncomeStatementCalculation
    end
  end

  describe "is_valid?" do
    it "returns true if the income statement and balance sheet are both valid" do
      @filing.is_valid?.should == (@filing.income_statement.is_valid? and @filing.balance_sheet.is_valid?)
    end
  end

  describe "write_constructor" do
    before(:all) do
      file_name = "/tmp/finmodeling-annual-rpt.rb"
      item_name = "@annual_rpt"
      file = File.open(file_name, "w")
      @filing.write_constructor(file, item_name)
      file.close

      eval(File.read(file_name))

      @loaded_filing = eval(item_name)
    end

    it "writes itself to a file, and when reloaded, has the same periods" do
      expected_periods = @filing.balance_sheet.periods.map{|x| x.to_pretty_s}.join(',')
      @loaded_filing.balance_sheet.periods.map{|x| x.to_pretty_s}.join(',').should == expected_periods
    end
    it "writes itself to a file, and when reloaded, has the same net operating assets" do
      period = @filing.balance_sheet.periods.last
      expected_noa = @filing.balance_sheet.reformulated(period).net_operating_assets.total
      @loaded_filing.balance_sheet.reformulated(period).net_operating_assets.total.should be_within(1.0).of(expected_noa)
    end
    it "writes itself to a file, and when reloaded, has the same net financing income" do
      period = @filing.income_statement.periods.last
      expected_nfi = @filing.income_statement.reformulated(period).net_financing_income.total
      @loaded_filing.income_statement.reformulated(period).net_financing_income.total.should be_within(1.0).of(expected_nfi)
    end
  end
end
