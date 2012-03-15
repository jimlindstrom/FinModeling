# cash_change_calculation_spec.rb

require 'spec_helper'

describe FinModeling::CashChangeCalculation  do
  before(:all) do
    goog_2011_q3_report = "http://www.sec.gov/Archives/edgar/data/1288776/000119312511282235/0001193125-11-282235-index.htm"
    @filing = FinModeling::AnnualReportFiling.download(goog_2011_q3_report, do_caching=false) # FIXME: turn caching back on..
    @cfs_period_q1_thru_q3 = @filing.cash_flow_statement.periods.threequarterly.last

    @cash_changes = @filing.cash_flow_statement.cash_change_calculation

    bs_period_initial = @filing.balance_sheet.periods[-2]
    bs_period_final   = @filing.balance_sheet.periods[-1]

    @cash_initial = @filing.balance_sheet.assets_calculation.summary(bs_period_initial).rows[0][:val]
    @cash_final   = @filing.balance_sheet.assets_calculation.summary(bs_period_final  ).rows[0][:val]
    
    puts "initial cash: #{@cash_initial}"
    puts "final cash:   #{@cash_final}"

    @filing.cash_flow_statement.cash_change_calculation.summary(@cfs_period_q1_thru_q3).print

    @cash_changes.leaf_items(@cfs_period_q1_thru_q3).each do |item|
      puts "#{item.name}: #{item.def ? item.def["xbrli:balance"] : "nil"}"
    end
  end

  describe "summary(period)" do
    subject{ @cash_changes.summary(@cfs_period_q1_thru_q3) }
    it { should be_an_instance_of FinModeling::CalculationSummary }

    describe ".total" do
      subject{ @cash_changes.summary(@cfs_period_q1_thru_q3).total }
      it { should be_within(1.0).of(@cash_final - @cash_initial) }
    end
  end
end

