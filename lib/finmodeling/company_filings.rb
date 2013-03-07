module FinModeling
  class CompanyFilings < Array
    def re_bs_arr
      @re_bs_arr ||= self.map{ |filing| filing.balance_sheet.reformulated(filing.balance_sheet.periods.last) }
    end

    def re_is_arr
      @re_is_arr ||= ([nil] + self).each_cons(2).map do |prev_filing, filing| 
        filing.income_statement.latest_quarterly_reformulated(prev_filing ? prev_filing.income_statement : nil) 
      end
    end

    def re_cfs_arr
      @re_cfs_arr ||= ([nil] + self).each_cons(2).map do |prev_filing, filing| 
        filing.cash_flow_statement.latest_quarterly_reformulated(prev_filing ? prev_filing.cash_flow_statement : nil) 
      end
    end

    def balance_sheet_analyses
      if !@balance_sheet_analyses
        analyses = ([nil] + re_bs_arr).each_cons(2).map { |prev, cur| cur.analysis(prev) }
        analyses.delete_if{ |x| x.nil? }
        @balance_sheet_analyses = BalanceSheetAnalyses.new( analyses.inject(:+) )
      end
      return @balance_sheet_analyses
    end
  
    def income_statement_analyses
      if !@income_statement_analyses
        analyses = []
        self.each_with_index do |filing, idx|
          prev_re_bs = (idx > 0) ? re_bs_arr[idx-1] : nil
          prev_re_is = (idx > 0) ? re_is_arr[idx-1] : nil
          re_bs = re_bs_arr[idx]
          re_is = re_is_arr[idx]
    
          analyses << (re_is ? re_is.analysis(re_bs, prev_re_is, prev_re_bs) : FinModeling::ReformulatedIncomeStatement.empty_analysis )
        end

        analyses.delete_if{ |x| x.nil? }
        @income_statement_analyses = IncomeStatementAnalyses.new( analyses.inject(:+) )
      end
      return @income_statement_analyses
    end
   
    def cash_flow_statement_analyses
      if !@cash_flow_statement_analyses
        analyses = []
        self.each_with_index do |filing, idx|
          re_is  = re_is_arr[idx]
          re_cfs = re_cfs_arr[idx]
      
          analyses << (re_cfs ? re_cfs.analysis(re_is) : FinModeling::ReformulatedCashFlowStatement.empty_analysis)
        end

        analyses.delete_if{ |x| x.nil? }
        #@cash_flow_statement_analyses = CashFlowStatementAnalyses.new( analyses.inject(:+) )
        @cash_flow_statement_analyses = analyses.inject(:+)
        @cash_flow_statement_analyses.totals_row_enabled = false # FIXME: put this on the others too
      end
      return @cash_flow_statement_analyses
    end

    def disclosures(title_regex, period_type=nil)
      ds = nil
      self.each do |filing|
        cur_disclosures = filing.disclosures
        if ( disclosure = filing.disclosures.find{ |disc| disc.summary(:period => disc.periods.last)
                                                              .title
                                                              .gsub(/ \(.*/,'') =~ title_regex } )

          period = case period_type
            when nil        then disclosure.periods.last
            when :yearly    then disclosure.periods.yearly.last
            when :quarterly then disclosure.periods.quarterly.last
            else                 raise RuntimeError.new("bogus period type")
          end

          if period
            next_d = disclosure.summary(:period => period )
            next_d.header_row = CalculationHeader.new(:key => "",   :vals => [period.to_pretty_s.gsub(/.* to /,'')])

            ds = ds + next_d if  ds
            ds =      next_d if !ds
          end
        end
      end
      return ds
    end
  
    def choose_forecasting_policy
      if length < 3
        return FinModeling::GenericForecastingPolicy.new
      else
        isa = income_statement_analyses
        args = { }
        args[:revenue_growth] = isa.revenue_growth_row.valid_vals.mean
        args[:sales_pm      ] = isa.operating_pm_row.valid_vals.mean
        args[:sales_over_noa] = isa.sales_over_noa_row.valid_vals.mean
        args[:fi_over_nfa   ] = isa.fi_over_nfa_row.valid_vals.mean
        return FinModeling::ConstantForecastingPolicy.new(args)
      end
    end
  
    def forecasts(policy, num_quarters)
      f = Forecasts.new

      last_re_bs = self.last.balance_sheet.reformulated(self.last.balance_sheet.periods.last)

      last_last_is = (self.length >= 2) ? self[-2].income_statement : nil
      puts "warning: last_last_is is nil..." if !last_last_is
      last_re_is = self.last.income_statement.latest_quarterly_reformulated(last_last_is)
      raise RuntimeError.new("last_re_is is nil!") if !last_re_is

      num_quarters.times do |i|
        next_bs_period = last_re_bs.period.plus_n_months(3)
        next_is_period = last_re_is.period.plus_n_months(3)
  
        next_re_is = FinModeling::ReformulatedIncomeStatement.forecast_next(next_is_period, policy, last_re_bs, last_re_is)
        next_re_bs = FinModeling::ReformulatedBalanceSheet   .forecast_next(next_bs_period, policy, last_re_bs, next_re_is)

        f.reformulated_income_statements << next_re_is
        f.reformulated_balance_sheets    << next_re_bs

        last_last_re_is, last_re_bs, last_re_is = [last_re_is, next_re_bs, next_re_is]
      end

      return f
    end

  end
end
