module FinModeling
  class Forecasts
    attr_accessor :reformulated_income_statements, :reformulated_balance_sheets

    def initialize
      @reformulated_income_statements = []
      @reformulated_balance_sheets    = []
    end

    def balance_sheet_analyses(filings)
      if !@balance_sheet_analyses
        prev_filing = filings.last
        prev_re_bs = prev_filing.balance_sheet.reformulated(prev_filing.balance_sheet.periods.last)
        @reformulated_balance_sheets.each do |re_bs|
          next_analysis = re_bs.analysis(prev_re_bs)
    
          @balance_sheet_analyses = @balance_sheet_analyses + next_analysis if  @balance_sheet_analyses
          @balance_sheet_analyses =                           next_analysis if !@balance_sheet_analyses
          prev_re_bs = re_bs
        end
        @balance_sheet_analyses = BalanceSheetAnalyses.new(@balance_sheet_analyses)
      end
      return @balance_sheet_analyses
    end
  
    def income_statement_analyses(filings, expected_rate_of_return)
      if !@income_statement_analyses
        prev_filing = filings.last
        prev_re_bs = prev_filing.balance_sheet.reformulated(prev_filing.balance_sheet.periods.last)
        prev_prev_is = (filings.length > 2) ? filings[-2].income_statement : nil
        prev_re_is = prev_filing.income_statement.latest_quarterly_reformulated(prev_cis=nil, prev_prev_is, prev_prev_cis=nil)
      
        @reformulated_income_statements.zip(@reformulated_balance_sheets).each do |re_is, re_bs|
          next_analysis = FinModeling::ReformulatedIncomeStatement.empty_analysis                if !re_is
          next_analysis = re_is.analysis(re_bs, prev_re_is, prev_re_bs, expected_rate_of_return) if  re_is
        
          @income_statement_analyses = @income_statement_analyses + next_analysis if  @income_statement_analyses
          @income_statement_analyses =                              next_analysis if !@income_statement_analyses
      
          prev_re_bs, prev_re_is  = [re_bs, re_is]
        end
        @income_statement_analyses = IncomeStatementAnalyses.new(@income_statement_analyses)
      end
      return @income_statement_analyses
    end

  end
end
