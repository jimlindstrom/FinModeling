# company_filing_spec.rb

require 'spec_helper'

describe FinModeling::CompanyFiling  do
  let(:company) { FinModeling::Company.new(FinModeling::Mocks::Entity.new) }
  let(:filing_url) { company.annual_reports.last.link }

  subject { FinModeling::CompanyFiling.download filing_url }

  describe "#download" do
    it { should be_a FinModeling::CompanyFiling }
  end

  describe ".print_presentations" do
    it { should respond_to(:print_presentations) }
  end

  describe ".print_calculations" do
    it { should respond_to(:print_calculations) }
  end

  describe ".disclosures" do
    subject { (FinModeling::CompanyFiling.download filing_url).disclosures }

    it { should be_an_instance_of Array }
    it { should_not be_empty }
    its(:first) { should be_a FinModeling::CompanyFilingCalculation }
  end
end
