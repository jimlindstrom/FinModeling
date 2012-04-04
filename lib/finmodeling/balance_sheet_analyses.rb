module FinModeling

  class BalanceSheetAnalyses < CalculationSummary
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
      lr = noa_growth_row.valid_vals.linear_regression
      puts "\t\tNOA growth: "+
           "a:#{lr.a.to_s.cap_decimals(4)}, "+
           "b:#{lr.b.to_s.cap_decimals(4)}, "+
           "r:#{lr.r.to_s.cap_decimals(4)}, "+
           "var:#{noa_growth_row.valid_vals.variance.to_s.cap_decimals(4)}"
    end

    def noa_growth_row
      find_row_by_key('NOA Growth')
    end

    def find_row_by_key(key) # FIXME: move this to CalculationSummary
      self.rows.find{ |x| x.key == key }
    end
  end

end

