# equity_change_calculation_spec.rb

require 'spec_helper'

describe FinModeling::EquityChangeCalculation  do
  before(:all) do
    deere_2011_annual_rpt = "http://www.sec.gov/Archives/edgar/data/315189/000110465910063219/0001104659-10-063219-index.htm"
    @filing = FinModeling::AnnualReportFiling.download(deere_2011_annual_rpt)
    @ses_period = @filing.shareholder_equity_statement.periods.last

    @equity_changes = @filing.shareholder_equity_statement.equity_change_calculation

    bs_period_initial = @filing.balance_sheet.periods[-2]
    bs_period_final   = @filing.balance_sheet.periods[-1]

    @equity_plus_minority_int_initial = @filing.balance_sheet.reformulated(bs_period_initial).common_shareholders_equity.total + 
                                        @filing.balance_sheet.reformulated(bs_period_initial).minority_interest         .total
    @equity_plus_minority_int_final   = @filing.balance_sheet.reformulated(bs_period_final)  .common_shareholders_equity.total +
                                        @filing.balance_sheet.reformulated(bs_period_final)  .minority_interest         .total
  end

  describe ".summary" do
    subject{ @equity_changes.summary(:period => @ses_period) }

    it { should be_an_instance_of FinModeling::CalculationSummary }

    describe ".total" do
      subject{ @equity_changes.summary(:period => @ses_period).total }
      it { should be_within(1.0).of(@equity_plus_minority_int_final - @equity_plus_minority_int_initial) }
    end
  end
end

