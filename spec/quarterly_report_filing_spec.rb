# quarterly_report_filing_spec.rb

require 'spec_helper'

describe FinModeling::QuarterlyReportFiling  do
  before(:all) do
    company = FinModeling::Company.new(FinModeling::Mocks::Entity.new)
    filing_url = company.quarterly_reports.last.link
    FinModeling::Config::disable_caching
    @filing = FinModeling::QuarterlyReportFiling.download(filing_url)
    FinModeling::Config::enable_caching
  end

  subject { @filing }
  its(:balance_sheet)                { should be_a FinModeling::BalanceSheetCalculation }
  its(:income_statement)             { should be_a FinModeling::IncomeStatementCalculation }
  its(:cash_flow_statement)          { should be_a FinModeling::CashFlowStatementCalculation }

  context "when the report doesn't have a statement of shareholders' equity" do
    its(:has_a_shareholder_equity_statement?) { should be_false }
    #its(:is_valid?) { should == [@filing.income_statement, 
    #                             @filing.balance_sheet, 
    #                             @filing.cash_flow_statement].all?{|x| x.is_valid?} }  # FIXME: this is failing, but I'm not sure how I want it to work.
  end

  context "after write_constructor()ing it to a file and then eval()ing the results" do
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

    it "writes itself to a file, and saves a schema version of 1.3" do
      @schema_version.should be == 1.3
    end

    subject { @loaded_filing }
    its(:balance_sheet)                { should have_the_same_periods_as(@filing.balance_sheet) }
    its(:balance_sheet)                { should have_the_same_reformulated_last_total(:net_operating_assets).as(@filing.balance_sheet) }
    its(:income_statement)             { should have_the_same_reformulated_last_total(:net_financing_income).as(@filing.income_statement) }
    its(:cash_flow_statement)          { should have_the_same_last_total(:cash_change_calculation).as(@filing.cash_flow_statement) }
    its(:disclosures)                  { should have_the_same_last_total(:first).as(@filing.disclosures) }
  end
end
