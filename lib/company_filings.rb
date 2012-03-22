module FinModeling
  class CompanyFilings < Array
    def balance_sheet_analyses
      if !@balance_sheet_analyses
        re_bs = nil
        @balance_sheet_analyses = nil
    
        self.each do |filing|
          prev_re_bs = re_bs
          re_bs = filing.balance_sheet.reformulated(filing.balance_sheet.periods.last)
          next_analysis = re_bs.analysis(prev_re_bs)
    
          @balance_sheet_analyses = @balance_sheet_analyses + next_analysis if  @balance_sheet_analyses
          @balance_sheet_analyses =                           next_analysis if !@balance_sheet_analyses
        end
      
        @balance_sheet_analyses.totals_row_enabled = false  if @balance_sheet_analyses.is_a? FinModeling::MultiColumnCalculationSummary
        @balance_sheet_analyses.extend BalanceSheetAnalyses if @balance_sheet_analyses.is_a? FinModeling::MultiColumnCalculationSummary
      end
      return @balance_sheet_analyses
    end
  
    def income_statement_analyses
      if !@income_statement_analyses
        @income_statement_analyses = nil
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
      
        @income_statement_analyses.totals_row_enabled = false     if @income_statement_analyses.is_a? FinModeling::MultiColumnCalculationSummary
        @income_statement_analyses.extend IncomeStatementAnalyses if @income_statement_analyses.is_a? FinModeling::MultiColumnCalculationSummary
      end
      return @income_statement_analyses
    end
  
    def cash_flow_statement_analyses
      if !@cash_flow_statement_analyses
        @cash_flow_statement_analyses = nil
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
      
        @cash_flow_statement_analyses.totals_row_enabled = false if @cash_flow_statement_analyses.is_a? FinModeling::MultiColumnCalculationSummary
      
        return @cash_flow_statement_analyses
      end
      return @cash_flow_statement_analyses
    end
  
  end
end
