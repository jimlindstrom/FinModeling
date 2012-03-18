# reformulated_income_statement_spec.rb

require 'spec_helper'

describe FinModeling::ReformulatedBalanceSheet  do
  before(:all) do
    google_2010_annual_rpt = "http://www.sec.gov/Archives/edgar/data/1288776/000119312510030774/0001193125-10-030774-index.htm"
    filing = FinModeling::AnnualReportFiling.download google_2010_annual_rpt
    @bal_sheet= filing.balance_sheet

    @period = @bal_sheet.periods.last
    @prev_reformed_bal_sheet = @bal_sheet.reformulated(@period)

    google_2011_annual_rpt = "http://www.sec.gov/Archives/edgar/data/1288776/000119312512025336/0001193125-12-025336-index.htm"
    filing = FinModeling::AnnualReportFiling.download google_2011_annual_rpt
    @bal_sheet = filing.balance_sheet
    @period = @bal_sheet.periods.last
    @reformed_bal_sheet = @bal_sheet.reformulated(@period)

    @years_between_sheets = 2.0
  end

  describe "new" do
    it "takes an assets calculation and a liabs_and_equity calculation and a period and returns a CalculationSummary" do
      rbs = FinModeling::ReformulatedBalanceSheet.new(@period, @bal_sheet.assets_calculation.summary(:period=>@period), @bal_sheet.liabs_and_equity_calculation.summary(:period=>@period))
      rbs.should be_an_instance_of FinModeling::ReformulatedBalanceSheet
    end
  end

  describe "operating_assets" do
    it "returns a CalculationSummary" do
      @reformed_bal_sheet.operating_assets.should be_an_instance_of FinModeling::CalculationSummary
    end
    it "totals up to the right amount" do
      @reformed_bal_sheet.operating_assets.total.should be_within(0.1).of(26943000000.0)
    end
  end

  describe "financial_assets" do
    it "returns a CalculationSummary" do
      @reformed_bal_sheet.financial_assets.should be_an_instance_of FinModeling::CalculationSummary
    end
    it "totals up to the right amount" do
      @reformed_bal_sheet.financial_assets.total.should be_within(0.1).of(45631000000.0)
    end
  end

  describe "operating_liabilities" do
    it "returns a CalculationSummary" do
      @reformed_bal_sheet.operating_liabilities.should be_an_instance_of FinModeling::CalculationSummary
    end
    it "totals up to the right amount" do
      @reformed_bal_sheet.operating_liabilities.total.should be_within(0.1).of(6041000000.0)
    end
  end

  describe "financial_liabilities" do
    it "returns a CalculationSummary" do
      @reformed_bal_sheet.financial_liabilities.should be_an_instance_of FinModeling::CalculationSummary
    end
    it "totals up to the right amount" do
      @reformed_bal_sheet.financial_liabilities.total.should be_within(0.1).of(8388000000.0)
    end
  end

  describe "net_operating_assets" do
    it "returns a CalculationSummary" do
      @reformed_bal_sheet.net_operating_assets.should be_an_instance_of FinModeling::CalculationSummary
    end
    it "totals up to the right amount" do
      @reformed_bal_sheet.net_operating_assets.total.should be_within(0.1).of(20902000000.0)
    end
  end

  describe "net_financial_assets" do
    it "returns a CalculationSummary" do
      @reformed_bal_sheet.net_financial_assets.should be_an_instance_of FinModeling::CalculationSummary
    end
    it "totals up to the right amount" do
      @reformed_bal_sheet.net_financial_assets.total.should be_within(0.1).of(37243000000.0)
    end
  end

  describe "common_shareholders_equity" do
    it "returns a CalculationSummary" do
      @reformed_bal_sheet.common_shareholders_equity.should be_an_instance_of FinModeling::CalculationSummary
    end
    it "totals up to the right amount" do
      @reformed_bal_sheet.common_shareholders_equity.total.should be_within(0.1).of(58145000000.0)
    end
  end

  describe "composition_ratio" do
    it "totals up to the right amount" do
      ratio = @reformed_bal_sheet.net_operating_assets.total / @reformed_bal_sheet.net_financial_assets.total
      @reformed_bal_sheet.composition_ratio.should be_within(0.1).of(ratio)
    end
  end

  describe "noa_growth" do
    it "totals up to the right amount" do
      noa0 = @prev_reformed_bal_sheet.net_operating_assets.total
      noa1 = @reformed_bal_sheet.net_operating_assets.total
      expected_growth = (noa1 / noa0)**(1.0/@years_between_sheets) - 1.0
      @reformed_bal_sheet.noa_growth(@prev_reformed_bal_sheet).should be_within(0.001).of(expected_growth)
    end
  end

  describe "cse_growth" do
    it "totals up to the right amount" do
      cse0 = @prev_reformed_bal_sheet.common_shareholders_equity.total
      cse1 = @reformed_bal_sheet.common_shareholders_equity.total
      expected_growth = (cse1 / cse0)**(1.0/@years_between_sheets) - 1.0
      @reformed_bal_sheet.cse_growth(@prev_reformed_bal_sheet).should be_within(0.001).of(expected_growth)
    end
  end

  describe "analysis" do
    subject {@reformed_bal_sheet.analysis(@prev_reformed_bal_sheet) }
    it { should be_an_instance_of FinModeling::CalculationSummary }
    it "contains the expected rows" do
      expected_keys = ["NOA (000's)", "NFA (000's)", "CSE (000's)",
                       "Composition Ratio", "NOA Growth", "CSE Growth" ]

      subject.rows.map{ |row| row.key }.should == expected_keys
    end
  end

end

