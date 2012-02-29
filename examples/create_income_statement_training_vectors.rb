#!/usr/bin/env ruby

$LOAD_PATH << "."

require 'finmodeling'

def get_args
  if ARGV.length != 1
    puts "usage #{__FILE__} <stock symbol or report URL>"
    exit
  end

  args = { :stock_symbol => nil, :filing_url => nil }
  arg = ARGV[0]
  if arg =~ /http/
    args[:filing_url] = arg
  else
    args[:stock_symbol] = arg
  end

  return args
end

def get_company_filing_url(stock_symbol)
  company = FinModeling::Company.find(stock_symbol)
  raise RuntimeError.new("couldn't find company") if company.nil?
  raise RuntimeError.new("company has no annual reports") if company.annual_reports.length == 0
  filing_url = company.annual_reports.last.link

  return filing_url
end

def get_filing(filing_url)
  filing = FinModeling::AnnualReportFiling.download(filing_url)
  return filing
end

def print_income_statement(filing)
  period = filing.income_statement.net_income_calculation.periods.yearly.last
  filing.income_statement.net_income_calculation.summary(period).print
end

args = get_args
filing_url = args[:filing_url] || get_company_filing_url(args[:stock_symbol])
filing = get_filing(filing_url)
print_income_statement(filing) if filing.is_valid?
