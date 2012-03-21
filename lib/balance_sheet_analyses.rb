module FinModeling

  module BalanceSheetAnalyses
    def print_extras
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

    def find_row_by_key(key)
      self.rows.find{ |x| x.key == key }
    end
  end

end

