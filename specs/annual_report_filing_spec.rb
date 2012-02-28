# annual_report_filing_spec.rb

require 'spec_helper'

describe FinModeling::AnnualReportFiling  do
  before (:all) do
    company = FinModeling::Company.new(FinModeling::Mocks::Entity.new)
    filing_url = company.annual_reports.last.link
    @filing = FinModeling::AnnualReportFiling.download filing_url
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
end
