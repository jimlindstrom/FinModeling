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
    args[:stock_symbol] = arg.downcase
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

def print_items(filing)
  return if !filing.has_a_shareholder_equity_statement?
  items =  filing.shareholder_equity_statement.equity_change_calculation.leaf_items
  items.each do |item| 
    puts "                         { :eci_type=>:c, :item_string=>\"#{item.pretty_name}\" }," 
  end
end

args = get_args
filing_url = args[:filing_url] || get_company_filing_url(args[:stock_symbol])
filing = get_filing(filing_url)
print_items(filing)
