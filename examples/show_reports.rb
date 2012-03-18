#!/usr/bin/env ruby

$LOAD_PATH << "."

require 'finmodeling'

class Arguments
  def self.show_usage_and_exit
    puts "usage:"
    puts "\t#{__FILE__} <stock symbol> <start date, e.g. '2010-01-01'>"
    exit
  end
  
  def self.parse(args)
    a = { :stock_symbol => nil, :start_date => nil }
  
    self.show_usage_and_exit if args.length != 2
    a[:stock_symbol]  = args[0]
    a[:start_date] = Time.parse(args[1])
  
    return a
  end
end

args = Arguments.parse(ARGV)

company = FinModeling::Company.find(args[:stock_symbol])
raise RuntimeError.new("couldn't find company") if !company
puts "company name: #{company.name}"

filings = FinModeling::CompanyFilings.new(company.filings_since_date(args[:start_date]))

filings.balance_sheet_analyses.print
filings.income_statement_analyses.print
filings.cash_flow_statement_analyses.print

