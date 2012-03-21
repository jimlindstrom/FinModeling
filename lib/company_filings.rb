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
    
      analysis.totals_row_enabled = false  if analysis.is_a? FinModeling::MultiColumnCalculationSummary
      analysis.extend BalanceSheetAnalyses if analysis.is_a? FinModeling::MultiColumnCalculationSummary
    
      return analysis
    end
  
    def income_statement_analyses
      analysis = nil
      prev_re_bs, prev_re_is, prev_filing  = [nil, nil, nil]
    
      self.each do |filing|
        re_is = filing.income_statement.latest_quarterly_reformulated(prev_filing ? prev_filing.income_statement : nil)
        re_bs = filing.balance_sheet.reformulated(filing.balance_sheet.periods.last)
  
        next_analysis = FinModeling::ReformulatedIncomeStatement.empty_analysis if !re_is
        next_analysis = re_is.analysis(re_bs, prev_re_is, prev_re_bs)           if  re_is
      
        analysis = analysis + next_analysis if  analysis
        analysis =            next_analysis if !analysis
    
        prev_re_bs, prev_re_is, prev_filing  = [re_bs, re_is, filing]
      end
    
      analysis.totals_row_enabled = false     if analysis.is_a? FinModeling::MultiColumnCalculationSummary
      analysis.extend IncomeStatementAnalyses if analysis.is_a? FinModeling::MultiColumnCalculationSummary
    
      return analysis
    end
  
    def cash_flow_statement_analyses
      analysis = nil
      prev_filing, prev_re_cfs = [nil, nil]
    
      self.each do |filing|
        re_is = filing.income_statement.latest_quarterly_reformulated(prev_filing ? prev_filing.income_statement : nil)
        re_cfs = filing.cash_flow_statement.latest_quarterly_reformulated(prev_filing ? prev_filing.cash_flow_statement : nil)
    
        next_analysis = FinModeling::ReformulatedCashFlowStatement.empty_analysis if !re_cfs
        next_analysis = re_cfs.analysis(re_is)                                    if  re_cfs
      
        analysis = analysis + next_analysis if  analysis
        analysis =            next_analysis if !analysis
  
        prev_filing, prev_re_cfs = [filing, re_cfs]
      end
    
      analysis.totals_row_enabled = false if analysis.is_a? FinModeling::MultiColumnCalculationSummary
    
      return analysis
    end
  
  end
end
