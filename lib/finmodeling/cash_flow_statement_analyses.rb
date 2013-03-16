# encoding: utf-8

module FinModeling

  class CashFlowStatementAnalyses < CalculationSummary
    def initialize(calc_summary)
      @title              = calc_summary.title
      @rows               = calc_summary.rows
      @header_row         = calc_summary.header_row
      @key_width          = calc_summary.key_width
      @val_width          = calc_summary.val_width
      @max_decimals       = calc_summary.max_decimals
      @totals_row_enabled = false
    end

    def print_regressions # FIXME: rename
      lr = ni_over_c_row.valid_vals.linear_regression
      puts "\t\tNI / C: "+
           "a:#{lr.a.to_s.cap_decimals(4)}, "+
           "b:#{lr.b.to_s.cap_decimals(4)}, "+
           "r²:#{lr.r2.to_s.cap_decimals(4)}, "+
           "σ²:#{ni_over_c_row.valid_vals.variance.to_s.cap_decimals(4)}, " +
           ( (lr.r2 > 0.6) ? "strong fit" : ( (lr.r2 < 0.2) ? "weak fit [**]" : "avg fit") )
    end

    def ni_over_c_row
      find_row_by_key('NI / C')
    end

    def find_row_by_key(key) # FIXME: move this to CalculationSummary
      self.rows.find{ |x| x.key == key }
    end
  end

end

