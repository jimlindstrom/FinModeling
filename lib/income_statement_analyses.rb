module FinModeling

  module IncomeStatementAnalyses
    def print_extras
      if operating_pm_row && operating_pm_row.valid_vals.any?
        lr = operating_pm_row.valid_vals.linear_regression
        puts "\t\toperating pm: "+
             "a:#{lr.a.to_s.cap_decimals(4)}, "+
             "b:#{lr.b.to_s.cap_decimals(4)}, "+
             "r:#{lr.r.to_s.cap_decimals(4)}, "+
             "var:#{operating_pm_row.valid_vals.variance.to_s.cap_decimals(4)}"
      end

      if asset_turnover_row && asset_turnover_row.valid_vals.any?
        lr = asset_turnover_row.valid_vals.linear_regression
        puts "\t\tasset turnover: "+
             "a:#{lr.a.to_s.cap_decimals(4)}, "+
             "b:#{lr.b.to_s.cap_decimals(4)}, "+
             "r:#{lr.r.to_s.cap_decimals(4)}, "+
             "var:#{asset_turnover_row.valid_vals.variance.to_s.cap_decimals(4)}"
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

    def asset_turnover_row
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

