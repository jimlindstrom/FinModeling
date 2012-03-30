module FinModeling
  class CompanyFilings < Array
    def balance_sheet_analyses
      if !@balance_sheet_analyses
        re_bs = nil
        self.each do |filing|
          prev_re_bs = re_bs
          re_bs = filing.balance_sheet.reformulated(filing.balance_sheet.periods.last)
          next_analysis = re_bs.analysis(prev_re_bs)
    
          @balance_sheet_analyses = @balance_sheet_analyses + next_analysis if  @balance_sheet_analyses
          @balance_sheet_analyses =                           next_analysis if !@balance_sheet_analyses
        end
        @balance_sheet_analyses = BalanceSheetAnalyses.new(@balance_sheet_analyses)
      end
      return @balance_sheet_analyses
    end
  
    def income_statement_analyses
      if !@income_statement_analyses
        prev_re_bs, prev_re_is, prev_filing  = [nil, nil, nil]
        self.each do |filing|
          re_is = filing.income_statement.latest_quarterly_reformulated(prev_filing ? prev_filing.income_statement : nil)
          re_bs = filing.balance_sheet.reformulated(filing.balance_sheet.periods.last)
    
          next_analysis = FinModeling::ReformulatedIncomeStatement.empty_analysis if !re_is
          next_analysis = re_is.analysis(re_bs, prev_re_is, prev_re_bs)           if  re_is
        
          @income_statement_analyses = @income_statement_analyses + next_analysis if  @income_statement_analyses
          @income_statement_analyses =                              next_analysis if !@income_statement_analyses
      
          prev_re_bs, prev_re_is, prev_filing  = [re_bs, re_is, filing]
        end
        @income_statement_analyses = IncomeStatementAnalyses.new(@income_statement_analyses)
      end
      return @income_statement_analyses
    end
  
    def cash_flow_statement_analyses
      if !@cash_flow_statement_analyses
        prev_filing, prev_re_cfs = [nil, nil]
        self.each do |filing|
          re_is = filing.income_statement.latest_quarterly_reformulated(prev_filing ? prev_filing.income_statement : nil)
          re_cfs = filing.cash_flow_statement.latest_quarterly_reformulated(prev_filing ? prev_filing.cash_flow_statement : nil)
      
          next_analysis = FinModeling::ReformulatedCashFlowStatement.empty_analysis if !re_cfs
          next_analysis = re_cfs.analysis(re_is)                                    if  re_cfs
        
          @cash_flow_statement_analyses = @cash_flow_statement_analyses + next_analysis if  @cash_flow_statement_analyses
          @cash_flow_statement_analyses =                                 next_analysis if !@cash_flow_statement_analyses
    
          prev_filing, prev_re_cfs = [filing, re_cfs]
        end
        @cash_flow_statement_analyses.totals_row_enabled = false
      end
      return @cash_flow_statement_analyses
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
