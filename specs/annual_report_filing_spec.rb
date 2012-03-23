# annual_report_filing_spec.rb

require 'spec_helper'

describe FinModeling::AnnualReportFiling  do
  before(:all) do
    company = FinModeling::Company.new(FinModeling::Mocks::Entity.new)
    filing_url = company.annual_reports.last.link
    FinModeling::Config::disable_caching 
    @filing = FinModeling::AnnualReportFiling.download(filing_url)
  end

  after(:all) do
    FinModeling::Config::enable_caching 
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

  describe "cash_flow_statement" do
    it "returns the cash flow statement calculation" do
      @filing.cash_flow_statement.should be_an_instance_of FinModeling::CashFlowStatementCalculation
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
      schema_version_item_name = "@schema_version"
      item_name = "@annual_rpt"
      file = File.open(file_name, "w")
      @filing.write_constructor(file, item_name)
      file.close

      eval(File.read(file_name))

      @schema_version = eval(schema_version_item_name)
      @loaded_filing = eval(item_name)
    end

    it "writes itself to a file, and saves a schema version that's at least 1.0" do
      @schema_version.should be >= 1.0
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
    it "writes itself to a file, and when reloaded, has the same net change in cash" do
      period = @filing.cash_flow_statement.periods.last
	  expected_cash_change = @filing.cash_flow_statement.cash_change_calculation.summary(:period=>period).total
	  @loaded_filing.cash_flow_statement.cash_change_calculation.summary(:period=>period).total.should be_within(1.0).of(expected_cash_change)
    end
  end
end
