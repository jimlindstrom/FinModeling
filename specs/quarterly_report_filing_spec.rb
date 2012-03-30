# quarterly_report_filing_spec.rb

require 'spec_helper'

describe FinModeling::QuarterlyReportFiling  do
  before(:all) do
    company = FinModeling::Company.new(FinModeling::Mocks::Entity.new)
    filing_url = company.quarterly_reports.last.link
    FinModeling::Config::disable_caching 
    @filing = FinModeling::QuarterlyReportFiling.download(filing_url)
  end

  after(:all) do
    FinModeling::Config::enable_caching 
  end

  subject { @filing }
  its(:balance_sheet)       { should be_a FinModeling::BalanceSheetCalculation }
  its(:income_statement)    { should be_a FinModeling::IncomeStatementCalculation }
  its(:cash_flow_statement) { should be_a FinModeling::CashFlowStatementCalculation }

  its(:is_valid?) { should == (@filing.income_statement.is_valid? && @filing.balance_sheet.is_valid? && @filing.cash_flow_statement.is_valid?) }

  describe "write_constructor" do
    before(:all) do
      file_name = "/tmp/finmodeling-quarterly-rpt.rb"
      schema_version_item_name = "@schema_version"
      item_name = "@quarterly_rpt"
      file = File.open(file_name, "w")
      @filing.write_constructor(file, item_name)
      file.close

      eval(File.read(file_name))

      @schema_version = eval(schema_version_item_name)
      @loaded_filing = eval(item_name)
    end

    it "writes itself to a file, and saves a schema version of 1.1" do
      @schema_version.should be == 1.1
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
    it "writes itself to a file, and when reloaded, has the same disclosures" do
      period = @filing.disclosures.first.periods.last
      expected_total = @filing.disclosures.first.summary(:period=>period).total
      @loaded_filing.disclosures.first.summary(:period=>period).total.should == expected_total
    end

  end
end
