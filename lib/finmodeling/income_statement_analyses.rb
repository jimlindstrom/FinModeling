# encoding: utf-8

module FinModeling

  class IncomeStatementAnalyses < CalculationSummary
    def initialize(calc_summary)
      @title              = calc_summary.title
      @rows               = calc_summary.rows
      @header_row         = calc_summary.header_row
      @key_width          = calc_summary.key_width
      @val_width          = calc_summary.val_width
      @max_decimals       = calc_summary.max_decimals
      @totals_row_enabled = false
    end

    def print_regressions
      if revenue_growth_row && revenue_growth_row.valid_vals.any?
        lr = revenue_growth_row.valid_vals.linear_regression
        puts "\t\trevenue growth: "+
             "a:#{lr.a.to_s.cap_decimals(4)}, "+
             "b:#{lr.b.to_s.cap_decimals(4)}, "+
             "r²:#{lr.r2.to_s.cap_decimals(4)}, "+
             "σ²:#{revenue_growth_row.valid_vals.variance.to_s.cap_decimals(4)}, " +
             ( (lr.r2 > 0.6) ? "strong fit" : ( (lr.r2 < 0.2) ? "weak fit" : "avg fit") )
      end

      if sales_over_noa_row && sales_over_noa_row.valid_vals.any?
        lr = sales_over_noa_row.valid_vals.linear_regression
        puts "\t\tsales / noa:    "+
             "a:#{lr.a.to_s.cap_decimals(4)}, "+
             "b:#{lr.b.to_s.cap_decimals(4)}, "+
             "r²:#{lr.r2.to_s.cap_decimals(4)}, "+
             "σ²:#{sales_over_noa_row.valid_vals.variance.to_s.cap_decimals(4)}, " +
             ( (lr.r2 > 0.6) ? "strong fit" : ( (lr.r2 < 0.2) ? "weak fit" : "avg fit") )
      end

      if operating_pm_row && operating_pm_row.valid_vals.any?
        lr = operating_pm_row.valid_vals.linear_regression
        puts "\t\toperating pm:   "+
             "a:#{lr.a.to_s.cap_decimals(4)}, "+
             "b:#{lr.b.to_s.cap_decimals(4)}, "+
             "r²:#{lr.r2.to_s.cap_decimals(4)}, "+
             "σ²:#{operating_pm_row.valid_vals.variance.to_s.cap_decimals(4)}, " +
             ( (lr.r2 > 0.6) ? "strong fit" : ( (lr.r2 < 0.2) ? "weak fit" : "avg fit") )
      end

      if fi_over_nfa_row && fi_over_nfa_row.valid_vals.any?
        lr = fi_over_nfa_row.valid_vals.linear_regression
        puts "\t\tfi / nfa:       "+
             "a:#{lr.a.to_s.cap_decimals(4)}, "+
             "b:#{lr.b.to_s.cap_decimals(4)}, "+
             "r²:#{lr.r2.to_s.cap_decimals(4)}, "+
             "σ²:#{fi_over_nfa_row.valid_vals.variance.to_s.cap_decimals(4)}, " +
             ( (lr.r2 > 0.6) ? "strong fit" : ( (lr.r2 < 0.2) ? "weak fit" : "avg fit") )
      end
    end

    def revenue_growth_row
      find_row_by_key('Revenue Growth')
    end

    def operating_pm_row
      find_row_by_key('Operating PM')
    end

    def sales_over_noa_row
      find_row_by_key('Sales / NOA')
    end

    def fi_over_nfa_row
      find_row_by_key('FI / NFA')
    end

    def find_row_by_key(key)
      self.rows.find{ |x| x.key == key }
    end
  end

end

