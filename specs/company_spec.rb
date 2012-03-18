# company_spec.rb

require 'spec_helper'

describe FinModeling::Company  do
  before(:each) do
  end

  describe "initialize" do
    it "takes a SecQuery::Entity and creates a new company" do
      entity = SecQuery::Entity.find("aapl", {:relationships=>false, :transactions=>false, :filings=>true})
      FinModeling::Company.new(entity).should be_an_instance_of FinModeling::Company
    end
  end

  describe "find" do
    it "looks up a company by its stock ticker" do
      FinModeling::Company.find("aapl").should be_an_instance_of FinModeling::Company
    end
    it "returns nil if the stock symbol is invalid" do
      FinModeling::Company.find("bogus symbol").should be_nil
    end
  end

  describe "name" do
    it "returns the name of the company" do
      c = FinModeling::Company.find("aapl")
      c.name.should == "APPLE INC"
    end
  end

  describe "annual_reports" do
    before(:all) do
      @company = FinModeling::Company.find "aapl"
    end
    it "returns a CompanyFilings object " do
      @company.annual_reports.should be_an_instance_of FinModeling::CompanyFilings
    end
    it "returns an array of 10-K filings" do
      @company.annual_reports.last.term.should == "10-K"
    end
  end

  describe "quarterly_reports" do
    before(:all) do
      @company = FinModeling::Company.find "aapl"
    end
    it "returns a CompanyFilings object " do
      @company.quarterly_reports.should be_an_instance_of FinModeling::CompanyFilings
    end
    it "returns an array of 10-Q filings" do
      @company.quarterly_reports.last.term.should == "10-Q"
    end
  end

  describe "filings_since_date" do
    before(:all) do
      @company = FinModeling::Company.find "aapl"
    end
    it "returns a CompanyFilings object " do
      @company.filings_since_date(Time.parse("2010-01-01")).should be_an_instance_of FinModeling::CompanyFilings
    end
    it "returns an array of 10-Q and/or 10-K filings filed after the given date" do
      @company.filings_since_date(Time.parse("1994-01-01")).length.should == 11
    end
    it "returns an array of 10-Q and/or 10-K filings filed after the given date" do
      @company.filings_since_date(Time.parse("2010-01-01")).length.should == 9
    end
    it "returns an array of 10-Q and/or 10-K filings filed after the given date" do
      @company.filings_since_date(Time.parse("2011-01-01")).length.should == 5
    end
  end
end
