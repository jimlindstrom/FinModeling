module FinModeling

  class IncomeStatementAnalyses < CalculationSummary
    def initialize(calc_summary)
      @title              = calc_summary.title
      @rows               = calc_summary.rows
      @header_row         = calc_summary.header_row
      @num_value_columns  = calc_summary.num_value_columns
      @key_width          = calc_summary.key_width
      @val_width          = calc_summary.val_width
      @max_decimals       = calc_summary.max_decimals
      @totals_row_enabled = false
    end

    def print_extras
      if operating_pm_row && operating_pm_row.valid_vals.any?
        lr = operating_pm_row.valid_vals.linear_regression
        puts "\t\toperating pm: "+
             "a:#{lr.a.to_s.cap_decimals(4)}, "+
             "b:#{lr.b.to_s.cap_decimals(4)}, "+
             "r:#{lr.r.to_s.cap_decimals(4)}, "+
             "var:#{operating_pm_row.valid_vals.variance.to_s.cap_decimals(4)}"
      end

      if sales_over_noa_row && sales_over_noa_row.valid_vals.any?
        lr = sales_over_noa_row.valid_vals.linear_regression
        puts "\t\tsales / noa: "+
             "a:#{lr.a.to_s.cap_decimals(4)}, "+
             "b:#{lr.b.to_s.cap_decimals(4)}, "+
             "r:#{lr.r.to_s.cap_decimals(4)}, "+
             "var:#{sales_over_noa_row.valid_vals.variance.to_s.cap_decimals(4)}"
      end

      if revenue_growth_row && revenue_growth_row.valid_vals.any?
        lr = revenue_growth_row.valid_vals.linear_regression
        puts "\t\trevenue growth: "+
             "a:#{lr.a.to_s.cap_decimals(4)}, "+
             "b:#{lr.b.to_s.cap_decimals(4)}, "+
             "r:#{lr.r.to_s.cap_decimals(4)}, "+
             "var:#{revenue_growth_row.valid_vals.variance.to_s.cap_decimals(4)}"
      end

      if fi_over_nfa_row && fi_over_nfa_row.valid_vals.any?
        lr = fi_over_nfa_row.valid_vals.linear_regression
        puts "\t\tfi / nfa: "+
             "a:#{lr.a.to_s.cap_decimals(4)}, "+
             "b:#{lr.b.to_s.cap_decimals(4)}, "+
             "r:#{lr.r.to_s.cap_decimals(4)}, "+
             "var:#{fi_over_nfa_row.valid_vals.variance.to_s.cap_decimals(4)}"
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

