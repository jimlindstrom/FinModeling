#!/usr/bin/env ruby

$LOAD_PATH << "."

require 'finmodeling'

class Arguments
  def self.show_usage_and_exit
    puts "usage:"
    puts "\t#{__FILE__} <stock symbol> <start date, e.g. '2010-01-01'>"
    exit
  end
  
  def self.parse(args)
    a = { :stock_symbol => nil, :start_date => nil }
  
    self.show_usage_and_exit if args.length != 2
    a[:stock_symbol]  = args[0]
    a[:start_date] = Time.parse(args[1])
  
    return a
  end
end

class Filings < Array
  def balance_sheet_analysis
    prev_re_bs   = nil
    analysis     = nil
  
    self.each do |filing|
      period     = filing.balance_sheet.periods.last
      re_bs      = filing.balance_sheet.reformulated(period)
  
      analysis   = next_balance_sheet_analysis(analysis, prev_re_bs, re_bs)
      prev_re_bs = re_bs
    end
  
    analysis.totals_row_enabled = false
  
    return analysis
  end

  def income_statement_analysis
    analysis    = nil
    prev_re_bs  = nil
    prev_re_is  = nil
    prev_filing = nil
  
    self.each do |filing|
      re_is = get_or_construct_latest_quarterly_re_is(filing, prev_filing)
   
      bs_period   = filing.balance_sheet.periods.last
      re_bs       = filing.balance_sheet.reformulated(bs_period)

      analysis    = next_income_statement_analysis(analysis, prev_re_bs, prev_re_is, re_bs, re_is)
  
      prev_re_bs  = re_bs
      prev_re_is  = re_is
      prev_filing = filing
    end
  
    analysis.totals_row_enabled = false
  
    return analysis
  end

  def cash_flow_statement_analysis
    prev_re_cfs   = nil
    analysis      = nil
    prev_filing   = nil
  
    self.each do |filing|
      re_cfs      = get_or_construct_latest_quarterly_re_cfs(filing, prev_filing)
  
      analysis    = next_cash_flow_statement_analysis(analysis, prev_re_cfs, re_cfs)
      prev_re_cfs = re_cfs
      prev_filing = filing
    end
  
    analysis.totals_row_enabled = false
  
    return analysis
  end

  private

  def next_balance_sheet_analysis(prev_analysis, prev_re_bs, re_bs)
    analysis = re_bs.analysis(prev_re_bs)
  
    return (prev_analysis + analysis) if  prev_analysis
    return (                analysis) if !prev_analysis
  end
   
  def next_income_statement_analysis(prev_analysis, prev_re_bs, prev_re_is, re_bs, re_is)
    analysis = FinModeling::ReformulatedIncomeStatement.empty_analysis if !re_is
    analysis = re_is.analysis(re_bs, prev_re_is, prev_re_bs)           if  re_is
  
    return (prev_analysis + analysis) if  prev_analysis
    return (                analysis) if !prev_analysis
  end

  def next_cash_flow_statement_analysis(prev_analysis, prev_re_cfs, re_cfs)
    analysis = FinModeling::ReformulatedCashFlowStatement.empty_analysis if !re_cfs
    analysis = re_cfs.analysis                                           if  re_cfs
  
    return (prev_analysis + analysis) if  prev_analysis
    return (                analysis) if !prev_analysis
  end

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


args = Arguments.parse(ARGV)

company = FinModeling::Company.find(args[:stock_symbol])
raise RuntimeError.new("couldn't find company") if !company
puts "company name: #{company.name}"

filings = Filings.new(company.filings_since_date(args[:start_date]))

filings.balance_sheet_analysis.print
filings.income_statement_analysis.print
filings.cash_flow_statement_analysis.print

