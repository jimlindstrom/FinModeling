module FinModeling
  class CompanyFilings < Array
    def balance_sheet_analyses
      re_bs = nil
      analysis = nil
  
      self.each do |filing|
        prev_re_bs = re_bs
        re_bs = filing.balance_sheet.reformulated(filing.balance_sheet.periods.last)
        next_analysis = re_bs.analysis(prev_re_bs)
  
        analysis = analysis + next_analysis if  analysis
        analysis =            next_analysis if !analysis
      end
    
      analysis.totals_row_enabled = false
    
      return analysis
    end
  
    def income_statement_analyses
      analysis = nil
      prev_re_bs, prev_re_is, prev_filing  = [nil, nil, nil]
    
      self.each do |filing|
        re_is = latest_quarterly_re_is(filing, prev_filing)
        re_bs = filing.balance_sheet.reformulated(filing.balance_sheet.periods.last)
  
        next_analysis = FinModeling::ReformulatedIncomeStatement.empty_analysis if !re_is
        next_analysis = re_is.analysis(re_bs, prev_re_is, prev_re_bs)           if  re_is
      
        analysis = analysis + next_analysis if  analysis
        analysis =            next_analysis if !analysis
    
        prev_re_bs, prev_re_is, prev_filing  = [re_bs, re_is, filing]
      end
    
      analysis.totals_row_enabled = false
    
      return analysis
    end
  
    def cash_flow_statement_analyses
      analysis = nil
      prev_filing, prev_re_cfs = [nil, nil]
    
      self.each do |filing|
        re_cfs = latest_quarterly_re_cfs(filing, prev_filing)
    
        next_analysis = FinModeling::ReformulatedCashFlowStatement.empty_analysis if !re_cfs
        next_analysis = re_cfs.analysis                                           if  re_cfs
      
        analysis = analysis + next_analysis if  analysis
        analysis =            next_analysis if !analysis
  
        prev_filing, prev_re_cfs = [filing, re_cfs]
      end
    
      analysis.totals_row_enabled = false
    
      return analysis
    end
  
    private
     
    def latest_quarterly_re_is(filing, prev_filing)
      if filing.income_statement.net_income_calculation.periods.quarterly.any?
        is_period = filing.income_statement.net_income_calculation.periods.quarterly.last
        return filing.income_statement.reformulated(is_period)

      elsif !prev_filing
        return nil

      elsif filing.income_statement.net_income_calculation.periods.yearly.any? &&
            prev_filing.income_statement.net_income_calculation.periods.threequarterly.any?
        is_period = filing.income_statement.net_income_calculation.periods.yearly.last
        re_is     = filing.income_statement.reformulated(is_period)
  
        period_1q_thru_3q = prev_filing.income_statement.net_income_calculation.periods.threequarterly.last
        prev3q  = prev_filing.income_statement.reformulated(period_1q_thru_3q)
        re_is   = re_is - prev3q
        return re_is 
      end
  
      return nil
    end
  
    def latest_quarterly_re_cfs(filing, prev_filing)
      if filing.cash_flow_statement.cash_change_calculation.periods.quarterly.any?
        cfs_period = filing.cash_flow_statement.cash_change_calculation.periods.quarterly.last
        return filing.cash_flow_statement.reformulated(cfs_period)
  
      elsif !prev_filing
        return nil

      elsif filing.cash_flow_statement.cash_change_calculation.periods.yearly.any? &&
            prev_filing.cash_flow_statement.cash_change_calculation.periods.threequarterly.any?
        cfs_period = filing.cash_flow_statement.cash_change_calculation.periods.yearly.last
        re_cfs     = filing.cash_flow_statement.reformulated(cfs_period)
  
        period_1q_thru_3q = prev_filing.cash_flow_statement.cash_change_calculation.periods.threequarterly.last
        prev3q  = prev_filing.cash_flow_statement.reformulated(period_1q_thru_3q)
        re_cfs  = re_cfs - prev3q

        return re_cfs 
      end
  
      return nil
    end
  end
end
