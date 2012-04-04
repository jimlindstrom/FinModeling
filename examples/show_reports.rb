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
    puts "\t\t--show-disclosure <part of title>: show a particular disclosure over time"
    puts "\t\t--show-regressions: show the regressions of calculations that are used to do forecasts"
    exit
  end
   
  def self.parse(raw_args)
    parsed_args = self.default_options

    while raw_args.any? && raw_args.first =~ /^--/
      self.parse_next_option(raw_args, parsed_args)
    end
  
    self.show_usage_and_exit if raw_args.length != 2
    parsed_args[:stock_symbol] = raw_args[0]
    parsed_args[:start_date  ] = Time.parse(raw_args[1])
  
    return parsed_args
  end

  private

  def self.default_options
    { :stock_symbol     => nil, 
      :start_date       => nil, 
      :num_forecasts    => nil, 
      :show_regressions => false, 
      :disclosures      => [ ] }
  end


  def self.parse_next_option(raw_args, parsed_args)
    case raw_args.first.downcase
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
        self.show_usage_and_exit if raw_args.length < 2
        parsed_args[:num_forecasts] = raw_args[1].to_i
        self.show_usage_and_exit unless parsed_args[:num_forecasts] >= 1
        puts "Forecasting #{parsed_args[:num_forecasts]} periods"
        raw_args.shift

      when '--show-regressions'
        parsed_args[:show_regressions] = true
        puts "Showing regressions"

      when '--show-disclosure'
        self.show_usage_and_exit if raw_args.length < 2
        parsed_args[:disclosures] << raw_args[1]
        puts "Showing disclosure: #{parsed_args[:disclosures].last}"
        raw_args.shift

      else
        self.show_usage_and_exit

    end
    raw_args.shift
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
if args[:show_regressions] && filings.balance_sheet_analyses.respond_to?(:print_regressions)
  filings.balance_sheet_analyses.print_regressions 
end

is_analyses = filings.income_statement_analyses 
is_analyses += forecasts.income_statement_analyses(filings) if forecasts
is_analyses.totals_row_enabled = false 
is_analyses.print
if args[:show_regressions] && filings.income_statement_analyses.respond_to?(:print_regressions)
  filings.income_statement_analyses.print_regressions
end

filings.cash_flow_statement_analyses.print

args[:disclosures].each do |disclosure_title|
  title_regex = Regexp.new(disclosure_title, Regexp::IGNORECASE)
  disclosures   = filings.disclosures(title_regex, :quarterly)
  disclosures ||= filings.disclosures(title_regex, :yearly   )
  disclosures ||= filings.disclosures(title_regex            )
  if disclosures
    disclosures.auto_scale!
    disclosures.print
  else
    puts "Couldn't find disclosures called: #{title_regex}"
  end
end
