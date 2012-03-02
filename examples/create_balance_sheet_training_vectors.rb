#!/usr/bin/env ruby

$LOAD_PATH << "."

require 'finmodeling'

def get_args
  if ARGV.length != 2
    puts "usage #{__FILE__} <stock symbol or report URL> <assets | liabilities>"
    exit
  end

  args = { :stock_symbol => nil, :filing_url => nil, :assets_or_liabs => nil }
  arg = ARGV[0]
  if arg =~ /http/
    args[:filing_url] = arg
  else
    args[:stock_symbol] = arg.downcase
  end
  case ARGV[1]
    when "assets"
      args[:assets_or_liabs] = "assets"
    when "liabilities"
      args[:assets_or_liabs] = "liabilities"
    else
      puts "usage #{__FILE__} <stock symbol or report URL> <assets | liabilities>"
      exit
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

def print_assets(filing)
  period = filing.balance_sheet.assets_calculation.periods.last
  items = filing.balance_sheet.assets_calculation.leaf_items(period)
  items.each { |item| puts item.pretty_name }
  puts
end

def print_liabilities(filing)
  period = filing.balance_sheet.liabs_and_equity_calculation.periods.last
  items = filing.balance_sheet.liabs_and_equity_calculation.leaf_items(period)
  items.each { |item| puts item.pretty_name }
  puts
end

args = get_args
filing_url = args[:filing_url] || get_company_filing_url(args[:stock_symbol])
filing = get_filing(filing_url)
print_assets(filing)      if args[:assets_or_liabs] == "assets"
print_liabilities(filing) if args[:assets_or_liabs] == "liabilities"
