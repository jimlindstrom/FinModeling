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

  describe ".new" do
    it "takes an assets calculation and a liabs_and_equity calculation and a period and returns a CalculationSummary" do
      rbs = FinModeling::ReformulatedBalanceSheet.new(@period, 
                                                      @bal_sheet.assets_calculation          .summary(:period=>@period), 
                                                      @bal_sheet.liabs_and_equity_calculation.summary(:period=>@period))
      rbs.should be_a FinModeling::ReformulatedBalanceSheet
    end
  end

  describe ".operating_assets" do
    subject { @reformed_bal_sheet.operating_assets }
    it { should be_a FinModeling::CalculationSummary }
    let(:total_assets) { @bal_sheet.assets_calculation.summary(:period=>@period).total }
    its(:total) { should be_within(0.1).of(total_assets - @reformed_bal_sheet.financial_assets.total) }
  end

  describe ".financial_assets" do
    subject { @reformed_bal_sheet.financial_assets }
    it { should be_a FinModeling::CalculationSummary }
    let(:total_assets) { @bal_sheet.assets_calculation.summary(:period=>@period).total }
    its(:total) { should be_within(0.1).of(total_assets - @reformed_bal_sheet.operating_assets.total) }
  end

  describe ".operating_liabilities" do
    subject { @reformed_bal_sheet.operating_liabilities }
    it { should be_a FinModeling::CalculationSummary }
    let(:total_equity) { @reformed_bal_sheet.common_shareholders_equity.total }
    let(:total_l_and_e) { @bal_sheet.liabs_and_equity_calculation.summary(:period=>@period).total }
    let(:total_liabs) { total_l_and_e - total_equity }
    its(:total) { should be_within(0.1).of(total_liabs - @reformed_bal_sheet.financial_liabilities.total) }
  end

  describe ".financial_liabilities" do
    subject { @reformed_bal_sheet.financial_liabilities }
    it { should be_a FinModeling::CalculationSummary }
    let(:total_equity) { @reformed_bal_sheet.common_shareholders_equity.total }
    let(:total_l_and_e) { @bal_sheet.liabs_and_equity_calculation.summary(:period=>@period).total }
    let(:total_liabs) { total_l_and_e - total_equity }
    its(:total) { should be_within(0.1).of(total_liabs - @reformed_bal_sheet.operating_liabilities.total) }
  end

  describe ".net_operating_assets" do
    subject { @reformed_bal_sheet.net_operating_assets }
    it { should be_a FinModeling::CalculationSummary }
    its(:total) { should be_within(0.1).of(@reformed_bal_sheet.operating_assets.total - @reformed_bal_sheet.operating_liabilities.total) }
  end

  describe ".net_financial_assets" do
    subject { @reformed_bal_sheet.net_financial_assets }
    it { should be_a FinModeling::CalculationSummary }
    its(:total) { should be_within(0.1).of(@reformed_bal_sheet.financial_assets.total - @reformed_bal_sheet.financial_liabilities.total) }
  end

  describe ".minority_interest" do
    subject { @reformed_bal_sheet.minority_interest }
    it { should be_a FinModeling::CalculationSummary }
    its(:total) { should be_within(0.1).of(@reformed_bal_sheet.net_operating_assets.total + 
                                           @reformed_bal_sheet.net_financial_assets.total -
                                           @reformed_bal_sheet.common_shareholders_equity.total) }
  end

  describe ".common_shareholders_equity" do
    subject { @reformed_bal_sheet.common_shareholders_equity }
    it { should be_a FinModeling::CalculationSummary }
    its(:total) { should be_within(0.1).of(@reformed_bal_sheet.net_operating_assets.total + 
                                           @reformed_bal_sheet.net_financial_assets.total -
                                           @reformed_bal_sheet.minority_interest.total) }
  end

  describe ".composition_ratio" do
    subject { @reformed_bal_sheet.composition_ratio }
    it { should be_within(0.1).of(@reformed_bal_sheet.net_operating_assets.total / @reformed_bal_sheet.net_financial_assets.total) }
  end

  describe ".noa_growth" do
    subject { @reformed_bal_sheet.noa_growth(@prev_reformed_bal_sheet) }
    let(:noa0) { @prev_reformed_bal_sheet.net_operating_assets.total }
    let(:noa1) { @reformed_bal_sheet.net_operating_assets.total }
    let(:expected_growth) { FinModeling::Rate.new((noa1-noa0) / noa0).annualize(from=365.0*@years_between_sheets, to=365.0) }
    it { should be_within(0.001).of(expected_growth) }
  end

  describe ".cse_growth" do
    subject { @reformed_bal_sheet.cse_growth(@prev_reformed_bal_sheet) }
    let(:cse0) { @prev_reformed_bal_sheet.common_shareholders_equity.total }
    let(:cse1) { @reformed_bal_sheet.common_shareholders_equity.total }
    let(:expected_growth) { FinModeling::Rate.new((cse1-cse0) / cse0).annualize(from=365.0*@years_between_sheets, to=365.0) }
    it { should be_within(0.001).of(expected_growth) }
  end

  describe ".analysis" do
    subject {@reformed_bal_sheet.analysis(@prev_reformed_bal_sheet) }
    it { should be_a FinModeling::CalculationSummary }
    it "contains the expected rows" do
      expected_keys = ["NOA ($MM)", "NFA ($MM)", "Minority Interest ($MM)", "CSE ($MM)",
                       "Composition Ratio", "NOA Growth", "CSE Growth" ]

      subject.rows.map{ |row| row.key }.should == expected_keys
    end
  end

  describe "#forecast_next" do
    before (:all) do
      @company = FinModeling::Company.find("aapl")
      @filings = FinModeling::CompanyFilings.new(@company.filings_since_date(Time.parse("2010-10-01")))
      @policy = FinModeling::GenericForecastingPolicy.new
  
      prev_bs_period = @filings.last.balance_sheet.periods.last
      next_bs_period_value = prev_bs_period.value.next_month.next_month.next_month
      @next_bs_period = Xbrlware::Context::Period.new(next_bs_period_value)
  
      next_is_period_value = {"start_date" => prev_bs_period.value,
                              "end_date"   => prev_bs_period.value.next_month.next_month.next_month }
      @next_is_period = Xbrlware::Context::Period.new(next_is_period_value)
    end

    let(:last_re_is) { @filings.last.income_statement.latest_quarterly_reformulated(nil) }
    let(:last_re_bs) { @filings.last.balance_sheet.reformulated(@filings.last.balance_sheet.periods.last) }
    let(:next_re_is) { FinModeling::ReformulatedIncomeStatement.forecast_next(@next_is_period, @policy, last_re_bs, last_re_is) }

    subject { FinModeling::ReformulatedBalanceSheet.forecast_next(@next_bs_period, @policy, last_re_bs, next_re_is) }

    it { should be_a_kind_of FinModeling::ReformulatedBalanceSheet }
    it "should have the given period" do
      subject.period.to_pretty_s == @next_bs_period.to_pretty_s
    end
    it "should set minority interest to ...?" do
      pending "not sure how to treat this"
    end
    it "should set NOA to the same period's operating revenue over the policy's asset turnover" do
      expected_val = next_re_is.operating_revenues.total / FinModeling::Ratio.new(@policy.sales_over_noa_on(@next_bs_period.value)).yearly_to_quarterly
      subject.net_operating_assets.total.should == expected_val
    end
    it "should set CSE to last year's CSE plus this year's net income" do
      expected_val = last_re_bs.common_shareholders_equity.total + next_re_is.comprehensive_income.total
      subject.common_shareholders_equity.total.should == expected_val
    end
    it "should set NFA to the gap between CSE and NOA" do
      expected_val = subject.common_shareholders_equity.total - subject.net_operating_assets.total
      subject.net_financial_assets.total.should == expected_val
    end
    it "should have an analysis (with the same rows)" do
      subject.analysis(last_re_bs)
    end
  end
end

