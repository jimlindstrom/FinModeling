# company_filing_spec.rb

require 'spec_helper'

describe FinModeling::CompanyFiling  do
  describe "download" do
    before (:all) do
      company = FinModeling::Company.new(FinModeling::Mocks::Entity.new)
      @filing_url = company.annual_reports.last.link
    end

    it "returns the balance sheet calculation" do
      filing = FinModeling::CompanyFiling.download @filing_url
      filing.should be_an_instance_of FinModeling::CompanyFiling
    end
  end
end
