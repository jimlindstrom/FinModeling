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
        re_is = get_or_construct_latest_quarterly_re_is(filing, prev_filing)
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
        re_cfs      = get_or_construct_latest_quarterly_re_cfs(filing, prev_filing)
    
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
     
    def latest_quarterly_or_yearly_period(filing, periods)
      period = case filing.class.to_s
        when "FinModeling::AnnualReportFiling"    then periods.yearly.last
        when "FinModeling::FakeAnnualFiling"      then periods.yearly.last
  
        when "FinModeling::QuarterlyReportFiling" then periods.quarterly.last
        when "FinModeling::FakeQuarterlyFiling"   then periods.quarterly.last
        else raise "unexpected class: #{filing.class.to_s}"
      end
      raise "couldn't get period from #{filing.class.to_s}, #{periods.inspect}" if !period
  
      return period
    end
  
    def get_or_construct_latest_quarterly_re_is(filing, prev_filing)
      begin
        is_period   = latest_quarterly_or_yearly_period(filing, filing.income_statement.net_income_calculation.periods)
        re_is       = filing.income_statement.reformulated(is_period)
  
        if (filing.class.to_s == "FinModeling::AnnualReportFiling") || (filing.class.to_s == "FinModeling::FakeAnnualFiling")
          begin
            period_1q_thru_3q = prev_filing.income_statement.net_income_calculation.periods.threequarterly.last
            prev3q  = prev_filing.income_statement.reformulated(period_1q_thru_3q)
            re_is   = re_is - prev3q
          rescue
            puts "Warning: failed to turn an Annual Report (#{is_period.to_pretty_s}) into a Quarterly Report..."
            re_is   = nil
          end
        end
      rescue Exception => e  
        puts "Warning: failed to parse income statement."
        puts "\t" + e.message  
        puts "\t" + e.backtrace.inspect.gsub(/, /, "\n\t ")
        re_is   = nil
      end
  
      return re_is 
    end
  
    def get_or_construct_latest_quarterly_re_cfs(filing, prev_filing)
      if filing.cash_flow_statement.cash_change_calculation.periods.quarterly.any?
        cfs_period = filing.cash_flow_statement.cash_change_calculation.periods.quarterly.last
        return filing.cash_flow_statement.reformulated(cfs_period)
      end
  
      begin
        cfs_period   = latest_quarterly_or_yearly_period(filing, filing.cash_flow_statement.cash_change_calculation.periods)
        re_cfs       = filing.cash_flow_statement.reformulated(cfs_period)
  
        if (filing.class.to_s == "FinModeling::AnnualReportFiling") || (filing.class.to_s == "FinModeling::FakeAnnualFiling")
          begin
            period_1q_thru_3q = prev_filing.cash_flow_statement.cash_change_calculation.periods.threequarterly.last
            prev3q  = prev_filing.cash_flow_statement.reformulated(period_1q_thru_3q)
            re_cfs  = re_cfs - prev3q
          rescue
            puts "Warning: failed to turn an Annual Report (#{cfs_period.to_pretty_s}) into a Quarterly Report..."
            re_cfs   = nil
          end
        end
      rescue Exception => e  
        puts "Warning: failed to parse cash flow statement."
        puts "\t" + e.message  
        puts "\t" + e.backtrace.inspect.gsub(/, /, "\n\t ")
        re_cfs   = nil
      end
  
      return re_cfs 
    end
  end
end
