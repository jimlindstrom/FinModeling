# company_spec.rb

require 'spec_helper'

describe FinModeling::Company  do
  before(:each) do
  end

  describe "initialize" do
    it "takes a SecQuery::Entity and creates a new company" do
      SecQuery::Entity.should_receive(:find).and_return(FinModeling::Mocks::Entity.new)

      entity = filings=SecQuery::Entity.find("appl", {:relationships=>false, :transactions=>false, :filings=>true})
      FinModeling::Company.new(entity).should be_an_instance_of FinModeling::Company
    end
  end

  describe "find" do
    it "looks up a company by its stock ticker" do
      SecQuery::Entity.should_receive(:find).and_return(FinModeling::Mocks::Entity.new)

      FinModeling::Company.find("aapl").should be_an_instance_of FinModeling::Company
    end
    it "returns nil if the stock symbol is invalid" do
      SecQuery::Entity.should_receive(:find).and_raise(RuntimeError)

      FinModeling::Company.find("bogus symbol").should be_nil
    end
  end

  describe "name" do
    it "returns the name of the company" do
      SecQuery::Entity.should_receive(:find).and_return(FinModeling::Mocks::Entity.new)

      c = FinModeling::Company.find("aapl")
      c.name.should == "Apple Inc"
    end
  end

  describe "annual_reports" do
    it "returns an array of 10-K filings" do
      SecQuery::Entity.should_receive(:find).and_return(FinModeling::Mocks::Entity.new)

      company = FinModeling::Company.find "aapl"
      company.annual_reports.last.term.should == "10-K"
    end
  end

  describe "quarterly_reports" do
    it "returns an array of 10-Q filings" do
      SecQuery::Entity.should_receive(:find).and_return(FinModeling::Mocks::Entity.new)

      company = FinModeling::Company.find "aapl"
      company.quarterly_reports.last.term.should == "10-Q"
    end
  end
end
