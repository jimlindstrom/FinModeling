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

balance_sheet = filing.balance_sheet
raise RuntimeError.new("Couldn't find balance sheet") if balance_sheet.nil?
period = filing.balance_sheet.periods.last
puts "period: #{period.to_s}"

assets            = balance_sheet.assets
liabs_and_equity  = balance_sheet.liabs_and_equity

raise RuntimeError.new("Couldn't find assets") if assets.nil?
raise RuntimeError.new("Couldn't find liabs") if liabs_and_equity.nil?

puts "assets label: " + assets.label + " (#{assets.calculation.item_id})"
assets.leaf_items(period).each do |item| 
  puts "\t#{item.name}\t-#{item.value}" if item.def["xbrli:balance"] == "credit"
  puts "\t#{item.name}\t #{item.value}" if item.def["xbrli:balance"] == "debit"
end
puts "\ttotal: #{assets.leaf_items_sum(period)}"

puts "liabs/equity label: " + liabs_and_equity.label + " (#{liabs_and_equity.calculation.item_id})"
liabs_and_equity.leaf_items(period).each do |item| 
  puts "\t#{item.name}\t #{item.value}" if item.def["xbrli:balance"] == "credit"
  puts "\t#{item.name}\t-#{item.value}" if item.def["xbrli:balance"] == "debit"
end
puts "\ttotal: #{-liabs_and_equity.leaf_items_sum(period)}"

puts
