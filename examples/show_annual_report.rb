#!/usr/bin/env ruby

$LOAD_PATH << "."

require 'finmodeling'

def check_usage
  if ARGV.length != 1
    puts "usage #{__FILE__} <stock symbol>"
    exit
  end

  return stock_symbol = ARGV[0]
end

def get_company(stock_symbol)
  company = FinModeling::Company.find(stock_symbol)
  raise RuntimeError.new("couldn't find company") if company.nil?
  puts "company name: #{company.name}"

  return company
end

def get_filing(company)
  raise RuntimeError.new("company has no annual reports") if company.annual_reports.length == 0
  filing_url = company.annual_reports.last.link
  puts "url:          #{filing_url}\n"
  filing = FinModeling::AnnualReportFiling.download(filing_url)
end

def print_balance_sheet(filing)
  period = filing.balance_sheet.periods.last
  puts "Balance Sheet (#{period.to_s})"
  
  filing.balance_sheet.assets.summarize(           period, type_to_flip="credit", flip_total=false)
  filing.balance_sheet.liabs_and_equity.summarize( period, type_to_flip="debit",  flip_total=true)
end

def print_income_statement(filing)
  period = filing.income_statement.periods.last
  puts "Income Statement (#{period.to_s})"
  
  filing.income_statement.net_income.summarize(    period, type_to_flip="debit", flip_total=true)
end

stock_symbol = check_usage
company = get_company(stock_symbol)
filing = get_filing(company)
print_balance_sheet(filing)
print_income_statement(filing)

