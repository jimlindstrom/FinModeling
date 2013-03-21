require 'spec_helper'

describe FinModeling::ReOIValuation do
  before (:all) do
    @company = FinModeling::Company.find("aapl")
    @filings = FinModeling::CompanyFilings.new(@company.filings_since_date(Time.parse("2012-10-01")))
    @cost_of_capital  = FinModeling::Rate.new(0.086) # 8.6% (made up)
    @forecasts = @filings.forecasts(@filings.choose_forecasting_policy(@cost_of_capital.value), num_forecast_periods=4)
    @num_shares = 934882640
  end

  describe ".new" do
    subject { FinModeling::ReOIValuation.new(@filings, @forecasts, @cost_of_capital, @num_shares) }

    it { should be_a FinModeling::ReOIValuation }
  end

  describe ".summary" do
    let(:valuation) { FinModeling::ReOIValuation.new(@filings, @forecasts, @cost_of_capital, @num_shares) }
    subject { valuation.summary }

    it { should be_a FinModeling::CalculationSummary }
    its(:title) { should == "ReOI Valuation" }
    its(:totals_row_enabled) { should be_false }
    it "should have the right row keys" do
      expected_keys = []
      expected_keys << "ReOI ($MM)"
      expected_keys << "PV(ReOI) ($MM)"
      expected_keys << "CV ($MM)"
      expected_keys << "PV(CV) ($MM)"
      expected_keys << "Book Value of Common Equity ($MM)"
      expected_keys << "Enterprise Value ($MM)"
      expected_keys << "NFA ($MM)"
      expected_keys << "Value of Common Equity ($MM)"
      expected_keys << "# Shares (MM)"
      expected_keys << "Value / Share ($)"
      subject.rows.map{ |x| x.key }.should == expected_keys
    end

    it "should show today, plus the forecasted periods" do
      period_strings = []
      period_strings << @filings.re_bs_arr.last.period.to_pretty_s
      period_strings += @forecasts.reformulated_balance_sheets.map{ |x| x.period.to_pretty_s + "E" }
      subject.header_row.vals.should == period_strings
    end

    it "should show all forecasted ReOIs" do
      prev_re_bses = [@filings.re_bs_arr.last] + @forecasts.reformulated_balance_sheets[0..-2]
      re_ises =  @forecasts.reformulated_income_statements
      re_ois = re_ises.zip(prev_re_bses).map{ |pair| pair[0].re_oi(pair[1], @cost_of_capital.value).to_nearest_million }

      reoi_row = subject.rows.find{ |x| x.key == "ReOI ($MM)" }
      reoi_row.vals[1..-1].should == re_ois
    end

    it "should the present value of the first N-1 ReOI forecasts" do
      reoi_row = subject.rows.find{ |x| x.key == "ReOI ($MM)" }
      pv_reoi_row = subject.rows.find{ |x| x.key == "PV(ReOI) ($MM)" }

      1.upto(reoi_row.vals.length-2) do |col_idx|
        days_from_now = valuation.periods[col_idx].value - Date.today
        discount_rate  = FinModeling::Rate.new(@cost_of_capital.value + 1.0)
        d = discount_rate.annualize(from_days=365, to_days=days_from_now)
        expected_pv_reoi = reoi_row.vals[col_idx] / d
        pv_reoi_row.vals[col_idx].should be_within(100.0).of(expected_pv_reoi) # rounding error bc the test is working off of nearest-million values
      end
    end

    it "should the continuing value, based on the last period's ReOI" do
      reoi_row = subject.rows.find{ |x| x.key == "ReOI ($MM)" }
      cv_row   = subject.rows.find{ |x| x.key == "CV ($MM)" }

      expected_cv = reoi_row.vals.last / @cost_of_capital.value # FIXME: this is an assumption of zero-growth CV
      cv_row.vals[-2].should be_within(10.0).of(expected_cv)
    end

    it "should the present value of the continuing value" do
      cv_row = subject.rows.find{ |x| x.key == "CV ($MM)" }
      pv_cv_row = subject.rows.find{ |x| x.key == "PV(CV) ($MM)" }

      1.upto(cv_row.vals.length-2) do |col_idx|
        if cv_row.vals[col_idx]
          days_from_now = valuation.periods[col_idx].value - Date.today
          discount_rate  = FinModeling::Rate.new(@cost_of_capital.value + 1.0)
          d = discount_rate.annualize(from_days=365, to_days=days_from_now)
          expected_pv_cv = cv_row.vals[col_idx] / d
          pv_cv_row.vals[col_idx].should be_within(2.0).of(expected_pv_cv)
        end
      end
    end

    it "should show the current book value of equity" do
      bv_cse_row = subject.rows.find{ |x| x.key == "Book Value of Common Equity ($MM)" }

      bv_cse_row.vals[0].should be_within(1.0).of(@filings.re_bs_arr.last.common_shareholders_equity.total.to_nearest_million)
    end

    it "should show the enterprise value" do
      pv_reoi_row = subject.rows.find{ |x| x.key == "PV(ReOI) ($MM)" }
      pv_cv_row = subject.rows.find{ |x| x.key == "PV(CV) ($MM)" }
      bv_cse_row = subject.rows.find{ |x| x.key == "Book Value of Common Equity ($MM)" }
      ev_row = subject.rows.find{ |x| x.key == "Enterprise Value ($MM)" }

      expected_ev = pv_reoi_row.vals[1..-2].inject(:+) + pv_cv_row.vals.select{ |x| x }.inject(:+) + bv_cse_row.vals.select{ |x| x }.inject(:+)

      ev_row.vals[0].should be_within(2.0).of(expected_ev)
    end

    it "should show the book value of net financial assets" do
      bv_nfa_row = subject.rows.find{ |x| x.key == "NFA ($MM)" }

      bv_nfa_row.vals[0].should be_within(1.0).of(@filings.re_bs_arr.last.net_financial_assets.total.to_nearest_million)
    end

    it "should show the value of common equity" do
      ev_row = subject.rows.find{ |x| x.key == "Enterprise Value ($MM)" }
      bf_nfa_row = subject.rows.find{ |x| x.key == "NFA ($MM)" }
      cse_row = subject.rows.find{ |x| x.key == "Value of Common Equity ($MM)" }

      expected_cse = ev_row.vals[0] + bf_nfa_row.vals[0]

      cse_row.vals[0].should be_within(1.0).of(expected_cse)
    end

    it "should show the book value of net financial assets" do
      num_shares_row = subject.rows.find{ |x| x.key == "# Shares (MM)" }

      num_shares_row.vals[0].should be_within(1.0).of(@num_shares.to_nearest_million)
    end

    it "should show the value per share" do
      cse_row = subject.rows.find{ |x| x.key == "Value of Common Equity ($MM)" }
      num_shares_row = subject.rows.find{ |x| x.key == "# Shares (MM)" }
      value_per_share_row = subject.rows.find{ |x| x.key == "Value / Share ($)" }

      expected_value_per_share = cse_row.vals[0] / num_shares_row.vals[0]

      value_per_share_row.vals[0].should be_within(1.0).of(expected_value_per_share)
    end

    it "should print successfully" do # FIXME: delete this. it's just for hacking
      subject.print
    end
  end

end
