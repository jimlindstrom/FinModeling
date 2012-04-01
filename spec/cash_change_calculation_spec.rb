# cash_change_calculation_spec.rb

require 'spec_helper'

describe FinModeling::CashChangeCalculation  do
  before(:all) do
    goog_2011_q3_report = "http://www.sec.gov/Archives/edgar/data/1288776/000119312511282235/0001193125-11-282235-index.htm"
    FinModeling::Config::disable_caching 
    @filing = FinModeling::AnnualReportFiling.download(goog_2011_q3_report)
    FinModeling::Config::enable_caching 
    @cfs_period_q1_thru_q3 = @filing.cash_flow_statement.periods.threequarterly.last

    @cash_changes = @filing.cash_flow_statement.cash_change_calculation

    bs_period_initial = @filing.balance_sheet.periods[-2]
    bs_period_final   = @filing.balance_sheet.periods[-1]

    @cash_initial = @filing.balance_sheet.assets_calculation.summary(:period => bs_period_initial).rows[0].vals.first
    @cash_final   = @filing.balance_sheet.assets_calculation.summary(:period => bs_period_final  ).rows[0].vals.first
  end

  describe "summary(period)" do
    subject{ @cash_changes.summary(:period => @cfs_period_q1_thru_q3) }
    it { should be_an_instance_of FinModeling::CalculationSummary }

    it "should have values with the right sign" do
      expected = [7033, 1011, 337, 1437, -61, 526, 3, -247, 268, 
                  -146, 72, 255, 70, 83, -2487, -43693, 33107, 
                  -358, 694, -395, -1350, -20, 61, 0, 8780, -8054, 74]

      actual = subject.rows.map{|row| (row.vals.first/1000.0/1000.0).round}

      if actual != expected
        num_errors = actual.zip(expected).map{ |x,y| x==y ? 0 : 1 }.inject(:+)
        puts "# errors: #{num_errors}"
      end

      actual.should == expected
    end

    describe ".total" do
      subject{ @cash_changes.summary(:period => @cfs_period_q1_thru_q3).total }
      it { should be_within(1.0).of(@cash_final - @cash_initial) }
    end
  end
end

