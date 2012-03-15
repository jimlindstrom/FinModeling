# factory_spec.rb

require 'spec_helper'

describe FinModeling::Factory  do
  before(:all) do
    google_2011_annual_rpt = "http://www.sec.gov/Archives/edgar/data/1288776/000119312512025336/0001193125-12-025336-index.htm"
    @filing_2011 = FinModeling::AnnualReportFiling.download google_2011_annual_rpt

    google_2009_annual_rpt = "http://www.sec.gov/Archives/edgar/data/1288776/000119312510030774/0001193125-10-030774-index.htm"
    @filing_2009 = FinModeling::AnnualReportFiling.download google_2009_annual_rpt
  end

  describe "BalanceSheetCalculation" do
    it "returns a BalanceSheetCalculation" do
      FinModeling::Factory.BalanceSheetCalculation.should be_an_instance_of FinModeling::BalanceSheetCalculation
    end

    context "when :sheet => 'google 10-k 2011-12-31 balance sheet'" do
      before(:all) do
        @real_bs = @filing_2011.balance_sheet
        @period = @real_bs.periods.last

        @bs = FinModeling::Factory.BalanceSheetCalculation(:sheet => 'google 10-k 2011-12-31 balance sheet')
      end
      it "returns the right periods" do
        expected_periods = @real_bs.periods.map{|x| x.to_pretty_s}
        @bs.periods.map{|x| x.to_pretty_s}.should == expected_periods
      end
      it "returns the right assets summary rows" do
        expected_rows = @real_bs.assets_calculation.summary(@period).rows.map{ |x| x.key }
        @bs.assets_calculation.summary(@period).rows.map{ |x| x.key }.should == expected_rows
      end
      it "returns the right assets summary values" do
        expected_rows = @real_bs.assets_calculation.summary(@period).rows.map{ |x| x.val.to_s }
        @bs.assets_calculation.summary(@period).rows.map{ |x| x.val.to_s }.should == expected_rows
      end
      it "returns the right liabilities and equity summary rows" do
        expected_rows = @real_bs.liabs_and_equity_calculation.summary(@period).rows.map{ |x| x.key }
        @bs.liabs_and_equity_calculation.summary(@period).rows.map{ |x| x.key }.should == expected_rows
      end
      it "returns the right liabilities and equity summary values" do
        expected_rows = @real_bs.liabs_and_equity_calculation.summary(@period).rows.map{ |x| x.val.to_s }
        @bs.liabs_and_equity_calculation.summary(@period).rows.map{ |x| x.val.to_s }.should == expected_rows
      end
    end

    context "when :sheet => 'google 10-k 2009-12-31 balance sheet'" do
      before(:all) do
        @real_bs = @filing_2009.balance_sheet
        @period = @real_bs.periods.last

        @bs = FinModeling::Factory.BalanceSheetCalculation(:sheet => 'google 10-k 2009-12-31 balance sheet')
      end
      it "returns the right periods" do
        expected_periods = @real_bs.periods.map{|x| x.to_pretty_s}
        @bs.periods.map{|x| x.to_pretty_s}.should == expected_periods
      end
      it "returns the right assets summary rows" do
        expected_rows = @real_bs.assets_calculation.summary(@period).rows.map{ |x| x.key }
        @bs.assets_calculation.summary(@period).rows.map{ |x| x.key }.should == expected_rows
      end
      it "returns the right assets summary values" do
        expected_rows = @real_bs.assets_calculation.summary(@period).rows.map{ |x| x.val.to_s }
        @bs.assets_calculation.summary(@period).rows.map{ |x| x.val.to_s }.should == expected_rows
      end
      it "returns the right liabilities and equity summary rows" do
        expected_rows = @real_bs.liabs_and_equity_calculation.summary(@period).rows.map{ |x| x.key }
        @bs.liabs_and_equity_calculation.summary(@period).rows.map{ |x| x.key }.should == expected_rows
      end
      it "returns the right liabilities and equity summary values" do
        expected_rows = @real_bs.liabs_and_equity_calculation.summary(@period).rows.map{ |x| x.val.to_s }
        @bs.liabs_and_equity_calculation.summary(@period).rows.map{ |x| x.val.to_s }.should == expected_rows
      end
    end
  end

  describe "incomeStatementCalculation" do
    it "returns a IncomeStatementCalculation" do
      FinModeling::Factory.IncomeStatementCalculation.should be_an_instance_of FinModeling::IncomeStatementCalculation
    end

    context "when :sheet => 'google 10-k 2011-12-31 income statment'" do
      before(:all) do
        @real_is = @filing_2011.income_statement
        @period = @real_is.periods.yearly.last

        @is = FinModeling::Factory.IncomeStatementCalculation(:sheet => 'google 10-k 2011-12-31 income statement')
      end
      it "returns the right last period" do
        expected = @real_is.periods.last.to_pretty_s
        @is.periods.last.to_pretty_s.should == expected
      end
      it "returns the right yearly periods" do
        expected_periods = @real_is.periods.yearly.map{|x| x.to_pretty_s}
        @is.periods.yearly.map{|x| x.to_pretty_s}.should == expected_periods
      end
      it "returns the right net income summary rows" do
        expected_rows = @real_is.net_income_calculation.summary(@period).rows.map{ |x| x.key }
        @is.net_income_calculation.summary(@period).rows.map{ |x| x.key }.should == expected_rows
      end
      it "returns the right net income summary values" do
        expected_rows = @real_is.net_income_calculation.summary(@period).rows.map{ |x| x.val.to_s }
        @is.net_income_calculation.summary(@period).rows.map{ |x| x.val.to_s }.should == expected_rows
      end
      context "when :delete_tax_item => true" do
        before(:all) do
          @is = FinModeling::Factory.IncomeStatementCalculation(:sheet => 'google 10-k 2011-12-31 income statement',
                                                                :delete_tax_item => true)
        end
        it "does not include the income tax item" do
          keys = @is.net_income_calculation.summary(@period).rows.map{ |x| x.key.to_s }
          keys.select{ |key| key.downcase =~ /tax/ }.should == []
        end
      end
      context "when :delete_sales_item => true" do
        before(:all) do
          @is = FinModeling::Factory.IncomeStatementCalculation(:sheet => 'google 10-k 2011-12-31 income statement',
                                                                :delete_sales_item => true)
        end
        it "does not include the revenues item" do
          keys = @is.net_income_calculation.summary(@period).rows.map{ |x| x.key.to_s }
          keys.select{ |key| key.downcase =~ /(sales)|(revenue)/ }.should == []
        end
      end
    end

    context "when :sheet => 'google 10-k 2009-12-31 income statement'" do
      before(:all) do
        @real_is = @filing_2009.income_statement
        @period = @real_is.periods.yearly.last

        @is = FinModeling::Factory.IncomeStatementCalculation(:sheet => 'google 10-k 2009-12-31 income statement')
      end
      it "returns the right last period" do
        @is.periods.last.to_pretty_s.should == @real_is.periods.last.to_pretty_s
      end
      it "returns the right yearly periods" do
        expected_periods = @real_is.periods.yearly.map{|x| x.to_pretty_s}
        @is.periods.yearly.map{|x| x.to_pretty_s}.should == expected_periods
      end
      it "returns the right net income summary rows" do
        expected_rows = @real_is.net_income_calculation.summary(@period).rows.map{ |x| x.key }
        @is.net_income_calculation.summary(@period).rows.map{ |x| x.key }.should == expected_rows
      end
      it "returns the right net income summary values" do
        expected_rows = @real_is.net_income_calculation.summary(@period).rows.map{ |x| x.val.to_s }
        @is.net_income_calculation.summary(@period).rows.map{ |x| x.val.to_s }.should == expected_rows
      end
    end
  end

end

