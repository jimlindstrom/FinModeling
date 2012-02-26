#!/usr/bin/env ruby

$LOAD_PATH << "."

require 'finmodeling'

if ARGV.length != 1
  puts "usage #{__FILE__} <stock symbol>"
  exit
end

stock_symbol = ARGV[0]
company = FinModeling::Company.find(stock_symbol)
raise RuntimeError.new("couldn't find company") if company.nil?
raise RuntimeError.new("company has no annual reports") if company.annual_reports.length == 0
puts "company name: #{company.name}"

filing_url = company.annual_reports.last.link
puts "url: #{filing_url}"
filing = FinModeling::AnnualReportFiling.download(filing_url)

###########

puts "Balance Sheet"
balance_sheet = filing.balance_sheet
period = balance_sheet.periods.last
puts "period: #{period.to_s}"

balance_sheet.assets.summarize(           period, type_to_flip="credit", flip_total=false)
balance_sheet.liabs_and_equity.summarize( period, type_to_flip="debit",  flip_total=true)

###########

puts "Income Statement"
inc_stmt = filing.income_statement
period = inc_stmt.periods.last
puts "period: #{period.to_s}"

inc_stmt.operating_expenses.summarize( period, type_to_flip="debit", flip_total=true)
inc_stmt.operating_income.summarize(   period, type_to_flip="debit", flip_total=true)
inc_stmt.net_income.summarize(         period, type_to_flip="debit", flip_total=true)

