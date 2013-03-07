# company_spec.rb

require 'spec_helper'

describe FinModeling::Company  do
  describe "initialize" do
    let(:entity) { SecQuery::Entity.find("aapl", {:relationships=>false, :transactions=>false, :filings=>true}) }
    subject { FinModeling::Company.new(entity) }
    it { should be_a FinModeling::Company }
  end

  describe "find" do
    context "when given a valid stock ticker" do
      subject { FinModeling::Company.find("aapl") } 
      it { should be_a FinModeling::Company }
    end
    context "when given a bogus stock ticker" do
      subject { FinModeling::Company.find("bogus symbol") } 
      it { should be_nil }
    end
  end

  let(:company) { FinModeling::Company.find("aapl") }

  describe "name" do
    subject { company.name }
    it { should == "APPLE INC" }
  end

  describe "annual_reports" do
    subject { company.annual_reports }
    it { should be_a FinModeling::CompanyFilings }
    specify { subject.all?{ |report| report.term == "10-K" }.should be_true }
  end

  describe "quarterly_reports" do
    subject { company.quarterly_reports }
    it { should be_a FinModeling::CompanyFilings }
    specify { subject.all?{ |report| report.term == "10-Q" }.should be_true }
  end

  describe "filings_since_date" do
    let(:start_date) { Time.parse("1994-01-01") }
    subject { company.filings_since_date(start_date) }
    it { should be_a FinModeling::CompanyFilings }

    context "when start date is 1994" do
      let(:start_date) { Time.parse("1994-01-01") }
      subject { company.filings_since_date(start_date) }
      it { should have(11).items }
    end
    context "when start date is 2010" do
      let(:start_date) { Time.parse("2010-01-01") }
      subject { company.filings_since_date(start_date) }
      it { should have( 9).items }
    end
    context "when start date is 2011" do
      let(:start_date) { Time.parse("2011-01-01") }
      subject { company.filings_since_date(start_date) }
      it { should have( 5).items }
    end
  end
end
