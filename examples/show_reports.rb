#!/usr/bin/env ruby

$LOAD_PATH << "."

require 'finmodeling'

class Arguments
  def self.show_usage_and_exit
    puts "usage:"
    puts "\t#{__FILE__} [options] <stock symbol> <start date, e.g. '2010-01-01'>"
    puts
    puts "\tOptions:"
    puts "\t\t--no-cache: disable caching"
    puts "\t\t--balance-detail: show details about the balance sheet calculation"
    puts "\t\t--income-detail: show details about the net income calculation"
    exit
  end
  
  def self.parse(args)
    a = { :stock_symbol => nil, :start_date => nil }

    while args.any? && args.first =~ /^--/
      case args.first.downcase
        when '--no-cache'
          FinModeling::Config.disable_caching
          puts "Caching is #{FinModeling::Config.caching_enabled? ? "enabled" : "disabled"}"
        when '--balance-detail'
          FinModeling::Config.enable_balance_detail
          puts "Balance sheet detail is #{FinModeling::Config.balance_detail_enabled? ? "enabled" : "disabled"}"
        when '--income-detail'
          FinModeling::Config.enable_income_detail
          puts "Net income detail is #{FinModeling::Config.income_detail_enabled? ? "enabled" : "disabled"}"
        else
          self.show_usage_and_exit
      end
      args = args[1..-1]
    end
  
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

bsa = filings.balance_sheet_analyses
bsa.print
bsa.print_extras if bsa.respond_to?(:print_extras)

isa = filings.income_statement_analyses
isa.print
isa.print_extras if isa.respond_to?(:print_extras)

filings.cash_flow_statement_analyses.print

