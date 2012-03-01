#!/usr/bin/env ruby

$LOAD_PATH << "."

require 'finmodeling'

if ARGV.length != 1
  puts "usage #{__FILE__} <stock symbol>"
  exit
end

filing_url = nil 
if !(ARGV[0] =~ /http/)
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
  puts "url: #{filing_url}"
else
  filing_url = ARGV[0]
end
filing = FinModeling::AnnualReportFiling.download(filing_url)

filing.print_presentations

filing.print_calculations
