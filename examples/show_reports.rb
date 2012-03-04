#!/usr/bin/env ruby

$LOAD_PATH << "."

require 'finmodeling'

def show_usage_and_exit
  puts "usage:"
  puts "\t#{__FILE__} <stock symbol> <10-k|10-q> <0, for most recent|-1 for prevous|-2, etc>"
  exit
end

def get_args
  show_usage_and_exit if ARGV.length < 3
  args = { :stock_symbol => nil, :filing_urls => nil, :report_type => nil, :report_offsets => nil }

  args[:stock_symbol]  = ARGV[0]
  args[:report_type]   = case ARGV[1].downcase
    when "10-k"
      :annual_report
    when "10-q"
      :quarterly_report
    else
      show_usage_and_exit
  end
  args[:report_offsets] = ARGV[2..-1].map{ |x| x.to_i }

  return args
end

def get_company_filing_urls(stock_symbol, report_type, report_offsets)
  company = FinModeling::Company.find(stock_symbol)
  raise RuntimeError.new("couldn't find company") if company.nil?
  puts "company name: #{company.name}"

  filing_urls = report_offsets.map do |report_offset|
    case report_type
      when :annual_report
        raise RuntimeError.new("company has no annual reports") if company.annual_reports.length == 0
        company.annual_reports[-1+report_offset].link
      when :quarterly_report
        raise RuntimeError.new("company has no quarterly reports") if company.quarterly_reports.length == 0
        company.quarterly_reports[-1+report_offset].link
    end
  end

  return filing_urls
end

def get_filing(filing_url, report_type)
  puts "url:          #{filing_url}\n"
  return FinModeling::AnnualReportFiling.download(   filing_url) if report_type == :annual_report
  return FinModeling::QuarterlyReportFiling.download(filing_url) if report_type == :quarterly_report
end

def print_balance_sheet(filing, report_type)
  period = filing.balance_sheet.periods.last
  puts "Balance Sheet (#{period.to_pretty_s})"
  
  filing.balance_sheet.assets_calculation.summary(period).print
  filing.balance_sheet.liabs_and_equity_calculation.summary(period).print
end

def print_reformulated_balance_sheet(filing, report_type)
  period = filing.balance_sheet.periods.last

  reformed_balance_sheet = filing.balance_sheet.reformulated(period)

  reformed_balance_sheet.net_operating_assets.print
  reformed_balance_sheet.net_financial_assets.print
  reformed_balance_sheet.common_shareholders_equity.print
end

def print_income_statement(filing, report_type)
  period  = filing.income_statement.net_income_calculation.periods.yearly.last    if report_type == :annual_report
  period  = filing.income_statement.net_income_calculation.periods.quarterly.last if report_type == :quarterly_report
  puts "Income Statement (#{period.to_pretty_s})"

  filing.income_statement.net_income_calculation.summary(period).print
end

def print_reformulated_income_statement(filing, report_type)
  period  = filing.income_statement.net_income_calculation.periods.yearly.last    if report_type == :annual_report
  period  = filing.income_statement.net_income_calculation.periods.quarterly.last if report_type == :quarterly_report

  reformed_inc_stmt  = filing.income_statement.reformulated(period)

  reformed_inc_stmt.gross_revenue.print
  reformed_inc_stmt.income_from_sales_before_tax.print
  reformed_inc_stmt.income_from_sales_after_tax.print
  reformed_inc_stmt.operating_income_after_tax.print
  reformed_inc_stmt.net_financing_income.print
  reformed_inc_stmt.comprehensive_income.print
end


args = get_args
args[:filing_urls] = get_company_filing_urls(args[:stock_symbol], args[:report_type], args[:report_offsets])

filing = get_filing(     args[:filing_url], args[:report_type])

print_balance_sheet(                filing, args[:report_type])
print_reformulated_balance_sheet(   filing, args[:report_type])
print_income_statement(             filing, args[:report_type])
print_reformulated_income_statement(filing, args[:report_type])

raise RuntimeError.new("filing is not valid") if !filing.is_valid?
