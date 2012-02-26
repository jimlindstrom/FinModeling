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
end
