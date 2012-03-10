# factory_spec.rb

require 'spec_helper'

describe FinModeling::Factory  do
  describe "income_statement_calculation" do
    it "returns a IncomeStatementCalculation" do
      FinModeling::Factory.IncomeStatementCalculation.should be_an_instance_of FinModeling::IncomeStatementCalculation
    end

    context "when :sheet => 'google 10-k 2011-12-31'" do
      before(:all) do
        google_2011_annual_rpt = "http://www.sec.gov/Archives/edgar/data/1288776/000119312512025336/0001193125-12-025336-index.htm"
        filing = FinModeling::AnnualReportFiling.download google_2011_annual_rpt
        @real_is = filing.income_statement
        @period = @real_is.periods.yearly.last

        @is = FinModeling::Factory.IncomeStatementCalculation(:sheet => 'google 10-k 2011-12-31')
      end
      it "returns the right last period" do
        @is.periods.last.to_pretty_s.should == @real_is.periods.last.to_pretty_s
      end
      it "returns the right yearly periods" do
        expected_periods = @real_is.periods.yearly.map{|x| x.to_pretty_s}
        @is.periods.yearly.map{|x| x.to_pretty_s}.should == expected_periods
      end
      it "returns the right net income summary rows" do
        expected_rows = @real_is.net_income_calculation.summary(@period).rows.map{ |x| x[:key] }
        @is.net_income_calculation.summary(@period).rows.map{ |x| x[:key] }.should == expected_rows
      end
      it "returns the right net income summary values" do
        expected_rows = @real_is.net_income_calculation.summary(@period).rows.map{ |x| x[:val].to_s }
        @is.net_income_calculation.summary(@period).rows.map{ |x| x[:val].to_s }.should == expected_rows
      end
    end

    context "when :sheet => 'google 10-k 2009-12-31'" do
      before(:all) do
        google_2009_annual_rpt = "http://www.sec.gov/Archives/edgar/data/1288776/000119312510030774/0001193125-10-030774-index.htm"
        filing = FinModeling::AnnualReportFiling.download google_2009_annual_rpt
        @real_is = filing.income_statement
        @period = @real_is.periods.yearly.last

        @is = FinModeling::Factory.IncomeStatementCalculation(:sheet => 'google 10-k 2009-12-31')
      end
      it "returns the right last period" do
        @is.periods.last.to_pretty_s.should == @real_is.periods.last.to_pretty_s
      end
      it "returns the right yearly periods" do
        expected_periods = @real_is.periods.yearly.map{|x| x.to_pretty_s}
        @is.periods.yearly.map{|x| x.to_pretty_s}.should == expected_periods
      end
      it "returns the right net income summary rows" do
        expected_rows = @real_is.net_income_calculation.summary(@period).rows.map{ |x| x[:key] }
        @is.net_income_calculation.summary(@period).rows.map{ |x| x[:key] }.should == expected_rows
      end
      it "returns the right net income summary values" do
        expected_rows = @real_is.net_income_calculation.summary(@period).rows.map{ |x| x[:val].to_s }
        @is.net_income_calculation.summary(@period).rows.map{ |x| x[:val].to_s }.should == expected_rows
      end
    end
  end

end

