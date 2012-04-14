# reformulated_income_statement_spec.rb

require 'spec_helper'

describe FinModeling::ReformulatedShareholderEquityStatement  do
  before(:all) do
    deere_2011_annual_rpt = "http://www.sec.gov/Archives/edgar/data/315189/000110465910063219/0001104659-10-063219-index.htm"
    filing = FinModeling::AnnualReportFiling.download deere_2011_annual_rpt
    stmt = filing.shareholder_equity_statement
    period = stmt.periods.last

    @equity_chg = stmt.equity_change_calculation.summary(:period => period)
    @re_ses = stmt.reformulated(period)
  end

  describe "transactions_with_shareholders" do
    subject { @re_ses.transactions_with_shareholders }
    it { should be_a FinModeling::CalculationSummary }
    its(:total) { should be_within(0.1).of( @equity_chg.filter_by_type(:share_issue  ).total +
                                            @equity_chg.filter_by_type(:minority_int ).total +
                                            @equity_chg.filter_by_type(:share_repurch).total +
                                            @equity_chg.filter_by_type(:common_div   ).total) }
  end

  describe "comprehensive_income" do
    subject { @re_ses.comprehensive_income }
    it { should be_a FinModeling::CalculationSummary }
    its(:total) { should be_within(0.1).of( @equity_chg.filter_by_type(:net_income   ).total +
                                            @equity_chg.filter_by_type(:oci          ).total +
                                            @equity_chg.filter_by_type(:preferred_div).total) }
  end

  describe "analysis" do
    subject { @re_ses.analysis }

    it { should be_a FinModeling::CalculationSummary }
    it "contains the expected rows" do
      expected_keys = [ "Tx w Shareholders ($MM)", "CI ($MM)" ]
      subject.rows.map{ |row| row.key }.should == expected_keys
    end
  end

end
