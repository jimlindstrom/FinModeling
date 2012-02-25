# company_filing_calculation_spec.rb

require 'spec_helper'

describe FinModeling::CompanyFilingCalculation  do
  before(:each) do
    @taxonomy = nil
    @calculation = FinModeling::Mocks::Calculation.new
  end

  describe "new" do
    it "takes a taxonomy and a xbrlware calculation and returns a CompanyFilingCalculation" do
      FinModeling::CompanyFilingCalculation.new(@taxonomy, @calculation).should be_an_instance_of FinModeling::CompanyFilingCalculation
    end
  end

  describe "label" do
    it "returns the calculation's label" do
      cfc = FinModeling::CompanyFilingCalculation.new(@taxonomy, @calculation)
      cfc.label.should == @calculation.label
    end
  end
end
