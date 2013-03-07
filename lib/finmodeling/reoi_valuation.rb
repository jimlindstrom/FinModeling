module FinModeling
  class ReOIValuation
    def initialize(filings, forecasts, discount_rate, num_shares)
      @filings, @forecasts, @discount_rate, @num_shares = [filings, forecasts, discount_rate, num_shares]
    end

    def summary
      s = CalculationSummary.new
      s.title = "ReOI Valuation"
      s.totals_row_enabled = false

      s.header_row = CalculationHeader.new(:key => "", :vals => periods.map{ |x| x.to_pretty_s + ((x.value > Date.today) ? "E" : "") })

      s.rows = [ ]

      s.rows << CalculationRow.new(:key => "ReOI ($MM)", :vals => reoi_vals.map{ |x| x ? x.to_nearest_million : nil })
      s.rows << CalculationRow.new(:key => "PV(ReOI) ($MM)", :vals => pv_reoi_vals.map{ |x| x ? x.to_nearest_million : nil })
      s.rows << CalculationRow.new(:key => "CV ($MM)", :vals => cv_vals.map{ |x| x ? x.to_nearest_million : nil })
      s.rows << CalculationRow.new(:key => "PV(CV) ($MM)", :vals => pv_cv_vals.map{ |x| x ? x.to_nearest_million : nil })
      s.rows << CalculationRow.new(:key => "Book Value of Common Equity ($MM)", :vals => bv_cse_vals.map{ |x| x ? x.to_nearest_million : nil })
      s.rows << CalculationRow.new(:key => "Enterprise Value ($MM)", :vals => ev_vals.map{ |x| x ? x.to_nearest_million : nil })
      s.rows << CalculationRow.new(:key => "NFA ($MM)", :vals => bv_nfa_vals.map{ |x| x ? x.to_nearest_million : nil })
      s.rows << CalculationRow.new(:key => "Value of Common Equity ($MM)", :vals => cse_vals.map{ |x| x ? x.to_nearest_million : nil })
      s.rows << CalculationRow.new(:key => "# Shares (MM)", :vals => num_shares_vals.map{ |x| x ? x.to_nearest_million : nil })
      s.rows << CalculationRow.new(:key => "Value / Share ($)", :vals => val_per_shares_vals.map{ |x| x ? x.to_nearest_penny : nil })

      return s
    end

    def periods
      @periods ||= [ @filings.re_bs_arr.last.period ] +
                   @forecasts.reformulated_balance_sheets.map{ |x| x.period }
    end

  private

    def reoi_vals
      prev_re_bses = [@filings.re_bs_arr.last] + @forecasts.reformulated_balance_sheets[0..-2]
      re_ises =  @forecasts.reformulated_income_statements
      re_ois = [nil] + re_ises.zip(prev_re_bses).map{ |pair| pair[0].re_oi(pair[1], @discount_rate.value-1.0) }
    end

    def pv_reoi_vals
      reoi_vals[0..-2].each_with_index.map do |reoi, idx|
        days_from_now = periods[idx].value - Date.today
        d = @discount_rate.annualize(from_days=365, to_days=days_from_now)
        reoi ? (reoi / d) : nil
      end + [nil]
    end

    def cv_vals
      vals = [nil]*periods.length
      vals[-2] = reoi_vals.last / (@discount_rate.value-1.0)
      vals
    end

    def pv_cv_vals
      cv_vals[0..-2].each_with_index.map do |cv, idx|
        days_from_now = periods[idx].value - Date.today
        d = @discount_rate.annualize(from_days=365, to_days=days_from_now)
        cv ? (cv / d) : nil
      end + [nil]
    end

    def bv_cse_vals
      vals = [nil]*periods.length
      vals[0] = @filings.re_bs_arr.last.common_shareholders_equity.total
      vals
    end

    def ev_vals
      vals = [nil]*periods.length
      vals[0] = (pv_reoi_vals[1..-2] + pv_cv_vals[-2..-2] + bv_cse_vals[0..0]).inject(:+)
      vals
    end

    def bv_nfa_vals
      vals = [nil]*periods.length
      vals[0] = @filings.re_bs_arr.last.net_financial_assets.total
      vals
    end

    def cse_vals
      vals = [nil]*periods.length
      vals[0] = ev_vals[0] + bv_nfa_vals[0]
      vals
    end

    def num_shares_vals
      vals = [nil]*periods.length
      vals[0] = @num_shares
      vals
    end

    def val_per_shares_vals
      vals = [nil]*periods.length
      vals[0] = cse_vals[0] / @num_shares
      vals
    end

  end
end
