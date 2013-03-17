#!/usr/bin/env ruby

require 'finmodeling'

class Arguments
  def self.show_usage_and_exit
    puts "usage:"
    puts "\t#{__FILE__} [options] <stock symbol> <10-k|10-q> <0, for most recent|-1 for prevous|-2, etc>"
    puts "\t#{__FILE__} [options] <report URL> <10-k|10-q>"
    puts
    puts "\tOptions:"
    puts "\t\t--no-cache: disables caching"
    puts "\t\t--show-disclosures: prints out all the disclosure calculations in the filing"
    exit
  end
  
  def self.parse(raw_args)
    parsed_args = { :stock_symbol => nil, :filing_url => nil, 
                    :report_type => nil, :report_offset => nil, 
                    :show_disclosures => false }

    while raw_args.any? && raw_args.first =~ /^--/
      case raw_args.first.downcase
        when '--no-cache'
          FinModeling::Config.disable_caching
          puts "Caching is #{FinModeling::Config.caching_enabled? ? "enabled" : "disabled"}"
        when '--show-disclosures'
          parsed_args[:show_disclosures] = true
          puts "Showing disclosures"
        else
          self.show_usage_and_exit
      end
      raw_args = raw_args[1..-1]
    end

    if raw_args[0] =~ /http/
      return self.parse_just_a_url(raw_args, parsed_args)
    else
      return self.parse_symbol_etc(raw_args, parsed_args)
    end
  end

  protected

  def self.parse_just_a_url(raw_args, parsed_args)
    self.show_usage_and_exit if raw_args.length != 2

    parsed_args[:filing_url]  = raw_args[0]
    parsed_args[:report_type] = case raw_args[1].downcase
      when "10-k"
        :annual_report
      when "10-q"
        :quarterly_report
      else
        self.show_usage_and_exit
    end

    return parsed_args
  end
  
  def self.parse_symbol_etc(raw_args, parsed_args)
    self.show_usage_and_exit if raw_args.length != 3
  
    parsed_args[:stock_symbol]  = raw_args[0]
    parsed_args[:report_type]   = case raw_args[1].downcase
      when "10-k"
        :annual_report
      when "10-q"
        :quarterly_report
      else
        self.show_usage_and_exit
    end
    parsed_args[:report_offset] = raw_args[2].to_i

    return parsed_args
  end
end

def get_company_filing_url(stock_symbol, report_type, report_offset)
  company = FinModeling::Company.find(stock_symbol)
  raise RuntimeError.new("couldn't find company") if company.nil?
  puts "company name: #{company.name}"

  filing_url = case report_type
    when :annual_report
      raise RuntimeError.new("company has no annual reports") if company.annual_reports.length == 0
      company.annual_reports[-1+report_offset].link
    when :quarterly_report
      raise RuntimeError.new("company has no quarterly reports") if company.annual_reports.length == 0
      company.quarterly_reports[-1+report_offset].link
  end

  return filing_url
end

def get_filing(filing_url, report_type)
  puts "url:          #{filing_url}\n"
  return FinModeling::AnnualReportFiling.download(   filing_url) if report_type == :annual_report
  return FinModeling::QuarterlyReportFiling.download(filing_url) if report_type == :quarterly_report
end

def print_balance_sheet(filing, report_type)
  period = filing.balance_sheet.periods.last
  puts "Balance Sheet (#{period.to_pretty_s})"
  
  summaries = []
  summaries << filing.balance_sheet.assets_calculation.summary(:period => period)
  summaries << filing.balance_sheet.liabs_and_equity_calculation.summary(:period => period)

  print_summaries(summaries)
end

def print_reformulated_balance_sheet(filing, report_type)
  period = filing.balance_sheet.periods.last

  reformed_balance_sheet = filing.balance_sheet.reformulated(period)

  summaries = []
  summaries << reformed_balance_sheet.net_operating_assets
  summaries << reformed_balance_sheet.net_financial_assets
  summaries << reformed_balance_sheet.common_shareholders_equity

  print_summaries(summaries)
end

def print_income_statement(filing, report_type)
  if filing.has_an_income_statement?
    period  = filing.income_statement.net_income_calculation.periods.yearly.last    if report_type == :annual_report
    period  = filing.income_statement.net_income_calculation.periods.quarterly.last if report_type == :quarterly_report
    puts "Income Statement (#{period.to_pretty_s})"
  
    summaries = []
    summaries << filing.income_statement.net_income_calculation.summary(:period => period)
  
    print_summaries(summaries)
  else
    puts "Filing has no income statement."
    puts 
  end
end

def print_comprehensive_income_statement(filing, report_type)
  if filing.has_a_comprehensive_income_statement?
    period  = filing.comprehensive_income_statement.comprehensive_income_calculation.periods.yearly.last    if report_type == :annual_report
    period  = filing.comprehensive_income_statement.comprehensive_income_calculation.periods.quarterly.last if report_type == :quarterly_report
    puts "Comprehensive Income Statement (#{period.to_pretty_s})"
  
    summaries = []
    summaries << filing.comprehensive_income_statement.comprehensive_income_calculation.summary(:period => period)
    #summaries << filing.comprehensive_income_statement.summary(:period => period) # when debugging, try printing the whole statement like this.
  
    print_summaries(summaries)
  else
    puts "Filing has no comprehensive income statement."
    puts 
  end
end

def print_reformulated_income_statement(filing, report_type)
  period  = filing.income_statement.net_income_calculation.periods.yearly.last    if report_type == :annual_report
  period  = filing.income_statement.net_income_calculation.periods.quarterly.last if report_type == :quarterly_report

  reformed_inc_stmt  = filing.income_statement.reformulated(period)

  summaries = []
  summaries << reformed_inc_stmt.gross_revenue
  summaries << reformed_inc_stmt.income_from_sales_before_tax
  summaries << reformed_inc_stmt.income_from_sales_after_tax
  summaries << reformed_inc_stmt.operating_income_after_tax
  summaries << reformed_inc_stmt.net_financing_income
  summaries << reformed_inc_stmt.comprehensive_income

  print_summaries(summaries)
end

def print_cash_flow_statement(filing, report_type)
  period = filing.cash_flow_statement.periods.yearly.last    if report_type == :annual_report
  period = filing.cash_flow_statement.periods.quarterly.last if report_type == :quarterly_report

  if period
    puts "cash flow statement (#{period.to_pretty_s})"
    
    summaries = []
    summaries << filing.cash_flow_statement.cash_change_calculation.summary(:period => period)
  
    print_summaries(summaries)
  else
    puts "WARNING: cash flow statement period is nil!"
  end
end

def print_reformulated_cash_flow_statement(filing, report_type)
  period = filing.cash_flow_statement.periods.yearly.last    if report_type == :annual_report
  period = filing.cash_flow_statement.periods.quarterly.last if report_type == :quarterly_report

  if period
    reformed_cash_flow_stmt  = filing.cash_flow_statement.reformulated(period)
  
    summaries = []
    summaries << reformed_cash_flow_stmt.cash_from_operations
    summaries << reformed_cash_flow_stmt.cash_investments_in_operations
    summaries << reformed_cash_flow_stmt.payments_to_debtholders
    summaries << reformed_cash_flow_stmt.payments_to_stockholders
    summaries << reformed_cash_flow_stmt.free_cash_flow
    summaries << reformed_cash_flow_stmt.financing_flows
  
    print_summaries(summaries)
  else
    puts "WARNING: reformulated cash flow statement period is nil!"
  end
end

def print_shareholder_equity_statement(filing, report_type)
  return if !filing.has_a_shareholder_equity_statement?
  period = filing.shareholder_equity_statement.periods.yearly.last    if report_type == :annual_report
  period = filing.shareholder_equity_statement.periods.quarterly.last if report_type == :quarterly_report
  puts "shareholder equity statement (#{period.to_pretty_s})"
  
  summaries = []
  summaries << filing.shareholder_equity_statement.equity_change_calculation.summary(:period => period)

  print_summaries(summaries)
end

def print_reformulated_shareholder_equity_statement(filing, report_type)
  return if !filing.has_a_shareholder_equity_statement?
  period = filing.shareholder_equity_statement.periods.yearly.last    if report_type == :annual_report
  period = filing.shareholder_equity_statement.periods.quarterly.last if report_type == :quarterly_report
  
  reformed_shareholder_equity_stmt = filing.shareholder_equity_statement.reformulated(period)

  summaries = []
  summaries << reformed_shareholder_equity_stmt.transactions_with_shareholders
  summaries << reformed_shareholder_equity_stmt.comprehensive_income

  print_summaries(summaries)
end

def print_disclosures(filing, report_type)
  puts "Disclosures"

  summaries = []
  filing.disclosures.each do |disclosure|
    summaries << disclosure.summary(:period => disclosure.periods.last)
  end

  print_summaries(summaries)
end

def print_summaries(summaries)
  summaries.each do |summary|
    summary.key_width = 60
    summary.val_width = 18
    summary.print
  end
end



args = Arguments.parse(ARGV)
if args[:filing_url].nil?
  args[:filing_url] = get_company_filing_url(args[:stock_symbol], args[:report_type], args[:report_offset])
end

filing = get_filing(args[:filing_url], args[:report_type])

print_balance_sheet(                            filing, args[:report_type])
print_reformulated_balance_sheet(               filing, args[:report_type])
print_income_statement(                         filing, args[:report_type])
print_comprehensive_income_statement(           filing, args[:report_type])
print_reformulated_income_statement(            filing, args[:report_type])
print_cash_flow_statement(                      filing, args[:report_type])
print_reformulated_cash_flow_statement(         filing, args[:report_type])
print_shareholder_equity_statement(             filing, args[:report_type])
print_reformulated_shareholder_equity_statement(filing, args[:report_type])
print_disclosures(                              filing, args[:report_type]) if args[:show_disclosures]

raise RuntimeError.new("filing is not valid") if !filing.is_valid?
