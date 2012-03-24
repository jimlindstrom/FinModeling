# forecasting_policy_spec.rb

require 'spec_helper'

describe FinModeling::Forecast  do
  before (:all) do
    @company = FinModeling::Company.find("aapl")
    @filings = FinModeling::CompanyFilings.new(@company.filings_since_date(Time.parse("2010-10-01")))
    @policy = FinModeling::ForecastingPolicy.new

    prev_bs_period = @filings.last.balance_sheet.periods.last
    next_bs_period_value = prev_bs_period.value.next_month.next_month.next_month
    @next_bs_period = Xbrlware::Context::Period.new(next_bs_period_value)

    next_is_period_value = {"start_date" => prev_bs_period.value,
                            "end_date"   => prev_bs_period.value.next_month.next_month.next_month }
    @next_is_period = Xbrlware::Context::Period.new(next_is_period_value)
  end

  describe "#next_reformulated_income_statement" do
    let(:last_re_bs) { @filings.last.balance_sheet.reformulated(@filings.last.balance_sheet.periods.last) }
    let(:last_re_is) { @filings.last.income_statement.latest_quarterly_reformulated(nil) }
    let(:next_re_is) { FinModeling::Forecast.next_reformulated_income_statement(@next_is_period, @policy, last_re_bs, last_re_is) }
    let(:next_re_bs) { FinModeling::Forecast.next_reformulated_balance_sheet(@next_bs_period, @policy, last_re_bs, next_re_is) }

    subject { next_re_is }

    it { should be_a_kind_of FinModeling::ReformulatedIncomeStatement } 
    it "should have the given period" do
      subject.period.to_pretty_s == @next_is_period.to_pretty_s
    end
    it "should set operating_revenue to last year's revenue times the revenue growth" do
      expected_val = last_re_is.operating_revenues.total * (1.0 + @policy.revenue_growth)
      subject.operating_revenues.total.should == expected_val
    end
    it "should set OISAT to operating revenue times sales PM" do
      expected_val = subject.operating_revenues.total * @policy.sales_pm
      subject.income_from_sales_after_tax.total.should == expected_val
    end
    it "should set NFI to fi_over_nfa times last year's NFA" do
      expected_val = last_re_bs.net_financial_assets.total * @policy.fi_over_nfa
      subject.net_financing_income.total.should == expected_val
    end
    it "should set comprehensive income to OISAT plus NFI" do
      expected_val = subject.income_from_sales_after_tax.total + subject.net_financing_income.total
      subject.comprehensive_income.total.should == expected_val
    end
    it "should have an empty analysis (with the same rows)" do
      subject.analysis(next_re_bs, last_re_is, last_re_bs)
    end
  end

  describe "#next_reformulated_balance_sheet" do
    let(:last_re_is) { @filings.last.income_statement.latest_quarterly_reformulated(nil) }
    let(:last_re_bs) { @filings.last.balance_sheet.reformulated(@filings.last.balance_sheet.periods.last) }
    let(:next_re_is) { FinModeling::Forecast.next_reformulated_income_statement(@next_is_period, @policy, last_re_bs, last_re_is) }

    subject { FinModeling::Forecast.next_reformulated_balance_sheet(@next_bs_period, @policy, last_re_bs, next_re_is) }

    it { should be_a_kind_of FinModeling::ReformulatedBalanceSheet }
    it "should have the given period" do
      subject.period.to_pretty_s == @next_bs_period.to_pretty_s
    end
    it "should set NOA to operating revenue over asset turnover" do # FIXME: isn't this off by a period?
      expected_val = next_re_is.operating_revenues.total / @policy.sales_over_noa
      subject.net_operating_assets.total.should == expected_val
    end
    it "should set CSE to last year's CSE plus this year's net income" do
      expected_val = last_re_bs.common_shareholders_equity.total / next_re_is.comprehensive_income.total
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
