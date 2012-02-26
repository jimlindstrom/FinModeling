#!/usr/bin/env ruby

$LOAD_PATH << "."

require 'finmodeling'


def left_justify(str, width)
  return str[0..(width-1  )]       if str.length == width
  return str[0..(width-1-3)]+"..." if str.length > width
  return str + (" " * (width - str.length))
end

def right_justify(str, width)
  return str[(-width  )..-1]       if str.length == width
  return str[(-width+3)..-1]+"..." if str.length > width
  return (" " * (width - str.length)) + str
end

def summarize_calculation(items, period, item_type_to_flip, flip_total)
  puts items.label + " (#{items.calculation.item_id})"
  items.leaf_items(period).each do |item| 
    row = "\t"
    item_name = item.name.gsub(/([a-z])([A-Z])/, '\1 \2')
    row += left_justify(item_name, 50)
    row += "  "

    item_val = item.value.to_f 
    raise RuntimeError.new("can't find balance definition in #{item.inspect}") if item.def.nil?
    item_val = -item_val if !item.def.nil? and item.def["xbrli:balance"] == item_type_to_flip

    item_val_str = item_val.to_s.reverse.scan(/(?:\d*\.)?\d{1,3}-?/).join(',').reverse

    row += right_justify(item_val_str, 18) 

    puts row
  end

  total_val = items.leaf_items_sum(period)
  total_val = -total_val if flip_total
  total_val_str = total_val.to_s.reverse.scan(/(?:\d*\.)?\d{1,3}-?/).join(',').reverse
  puts "\t#{left_justify("total", 50)}  #{right_justify(total_val_str, 18)}"
  puts
end


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

summarize_calculation(balance_sheet.assets,           period, type_to_flip="credit", flip_total=false)
summarize_calculation(balance_sheet.liabs_and_equity, period, type_to_flip="debit",  flip_total=true)

###########

puts "Income Statement"
inc_stmt = filing.income_statement
period = inc_stmt.periods.last
puts "period: #{period.to_s}"

summarize_calculation(inc_stmt.operating_expenses, period, type_to_flip="debit", flip_total=true)
summarize_calculation(inc_stmt.operating_income,   period, type_to_flip="debit", flip_total=true)
summarize_calculation(inc_stmt.net_income,         period, type_to_flip="debit", flip_total=true)

