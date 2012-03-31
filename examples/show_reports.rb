#!/usr/bin/env ruby

require 'finmodeling'

class Arguments
  def self.show_usage_and_exit
    puts "usage:"
    puts "\t#{__FILE__} [options] <stock symbol> <start date, e.g. '2010-01-01'>"
    puts
    puts "\tOptions:"
    puts "\t\t--num-forecasts <num>: how many periods to forecast"
    puts "\t\t--no-cache: disable caching"
    puts "\t\t--balance-detail: show details about the balance sheet calculation"
    puts "\t\t--income-detail: show details about the net income calculation"
    exit
  end
  
  def self.parse(args)
    a = { :stock_symbol => nil, :start_date => nil, :num_forecasts => nil }

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
        when '--num-forecasts'
          a[:num_forecasts] = args[1].to_i
          self.show_usage_and_exit unless a[:num_forecasts] >= 1
          puts "Forecasting #{a[:num_forecasts]} periods"
          args = args[1..-1]
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
if filings.empty?
  puts "No filings..."
  exit
end

forecasts = filings.forecasts(filings.choose_forecasting_policy, num_quarters=args[:num_forecasts]) if args[:num_forecasts]

bs_analyses = filings.balance_sheet_analyses 
bs_analyses += forecasts.balance_sheet_analyses(filings) if forecasts
bs_analyses.totals_row_enabled = false 
bs_analyses.print
filings.balance_sheet_analyses.print_extras if filings.balance_sheet_analyses.respond_to?(:print_extras)

is_analyses = filings.income_statement_analyses 
is_analyses += forecasts.income_statement_analyses(filings) if forecasts
is_analyses.totals_row_enabled = false 
is_analyses.print
filings.income_statement_analyses.print_extras if filings.income_statement_analyses.respond_to?(:print_extras)

filings.cash_flow_statement_analyses.print
