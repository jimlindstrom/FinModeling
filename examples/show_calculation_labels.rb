#!/usr/bin/env ruby

$LOAD_PATH << "."

require 'finmodeling'

if ARGV.length != 1
  puts "usage #{__FILE__} <stock symbol>"
  exit
end

company = FinModeling::Company.find(stock_symbol = ARGV[0])
if company.nil?
  puts "couldn't find company"
  exit
elsif company.annual_reports.length == 0
  puts "no annual reports"
  exit
end
puts "company name: #{company.name}"

filing_url = company.annual_reports.last.link
filing = FinModeling::AnnualReportFiling.download(filing_url)

balance_sheet = filing.balance_sheet
if balance_sheet.nil?
  puts "couldn't find balance sheet"
  exit
end

left_side  = balance_sheet.assets
right_side = balance_sheet.liabs_and_equity

if left_side.nil?
  puts "couldn't find assets"
else
  puts "assets label: " + left_side.label
end

if right_side.nil?
  puts "couldn't find liabs/equity"
else
  puts "liabs/equity label: " + right_side.label
end

