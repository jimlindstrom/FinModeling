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
  puts "company name: #{company.name}"
  raise RuntimeError.new("company has no annual reports") if company.annual_reports.length == 0
  filing_url = company.annual_reports.last.link

  return filing_url
end

def get_filing(filing_url)
  puts "url:          #{filing_url}\n"
  filing = FinModeling::AnnualReportFiling.download(filing_url)
  return filing
end

def print_balance_sheet(filing)
  period = filing.balance_sheet.periods.last
  puts "Balance Sheet (#{period.to_pretty_s})"
  
  filing.balance_sheet.assets_calculation.summary(          period, type_to_flip="credit", flip_total=false).print
  filing.balance_sheet.liabs_and_equity_calculation.summary(period, type_to_flip="debit",  flip_total=true ).print
end

def print_income_statement(filing)
  period  = filing.income_statement.net_income_calculation.periods.yearly.last
  puts "Income Statement (#{period.to_pretty_s})"

  summary = filing.income_statement.net_income_calculation.summary(period, type_to_flip="debit",  flip_total=true)

  summary.rows[0..-2].each do |row|
    isi = FinModeling::IncomeStatementItem.new(row[:key])
    row[:key] = "[#{isi.classify.to_s}] " + row[:key]
  end
  
  summary.print
end

FinModeling::IncomeStatementItem.load_vectors_and_train("specs/vectors/income_statement_training_vectors.txt")

args = get_args
filing_url = args[:filing_url] || get_company_filing_url(args[:stock_symbol])
filing = get_filing(filing_url)
print_balance_sheet(filing)
print_income_statement(filing)
raise RuntimeError.new("annual report is not valid") if !filing.is_valid?
