# annual_report_filing_spec.rb

require 'spec_helper'

describe FinModeling::AnnualReportFiling  do
  describe "balance_sheet" do
    context "given a valid annual report" do
      before (:all) do
        company = FinModeling::Company.new(FinModeling::Mocks::Entity.new)
        filing_url = company.annual_reports.last.link
        @filing = FinModeling::AnnualReportFiling.download filing_url
      end
      it "returns the balance sheet calculation" do
        @filing.balance_sheet.should be_an_instance_of FinModeling::BalanceSheetCalculation
      end
    end
  end
end
