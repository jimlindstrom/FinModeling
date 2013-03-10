#!/usr/bin/env ruby

require 'finmodeling'

class Arguments
  def self.show_usage_and_exit
    puts "usage:"
    puts "\t#{__FILE__} [options] <stock symbol> <start date, e.g. '2010-01-01'>"
    puts
    puts "\tOptions:"
    puts "\t\t--num-forecasts <num>: how many periods to forecast"
    puts "\t\t  --do-valuation: value the company's equity. (requires >= 2 forecasts)"
    puts "\t\t    --marginal-tax-rate <num>: default is 0.36 (36%) [UNUSED]"
    puts "\t\t    --before-tax-cost-of-debt <num>: default is 0.05 (5%) [UNUSED]"
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
    { :stock_symbol            => nil, 
      :start_date              => nil, 
      :num_forecasts           => nil, 
      :do_valuation            => false, 
      :marginal_tax_rate       => 0.36, 
      :before_tax_cost_of_debt => 0.05, 
      :show_regressions        => false, 
      :disclosures             => [ ] }
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

      when '--do-valuation'
        parsed_args[:do_valuation] = true
        puts "Doing valuation"

      when '--before-tax-cost-of-debt'
        self.show_usage_and_exit if raw_args.length < 2
        parsed_args[:before_tax_cost_of_debt] = raw_args[1].to_f
        self.show_usage_and_exit unless parsed_args[:before_tax_cost_of_debt] >= 0.00 && parsed_args[:before_tax_cost_of_debt] <= 1.00
        puts "before tax cost of debt: #{parsed_args[:before_tax_cost_of_debt]}"
        raw_args.shift

      when '--marginal-tax-rate'
        self.show_usage_and_exit if raw_args.length < 2
        parsed_args[:marginal_tax_rate] = raw_args[1].to_f
        self.show_usage_and_exit unless parsed_args[:marginal_tax_rate] >= 0.00 && parsed_args[:marginal_tax_rate] <= 1.00
        puts "marginal tax rate: #{parsed_args[:marginal_tax_rate]}"
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
filings.each do |filing|
  raise RuntimeError.new("filing is not valid") if !filing.is_valid?
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
    if (disclosures.header_row.vals - bs_analyses.header_row.vals).length == 0
      0.upto(bs_analyses.header_row.vals.length-1) do |idx|
        if bs_analyses.header_row.vals[idx] != disclosures.header_row.vals[idx]
          disclosures.insert_column_before(idx, "")
        end
      end
    end
    disclosures.print
  else
    puts "Couldn't find disclosures called: #{title_regex}"
  end
end

#	NFA		NFI		NFI/NFA			DCOC			D
#	-100		-2		 2%			 2%			 100
#	-100		 2		-2%			 0%			 100
#	 100		-2		-2%			 0%			-100
#	 100		 2		 2%			 0%			-100
if args[:do_valuation]
  if args[:num_forecasts] && args[:num_forecasts]>=2
    nfa  = filings.re_bs_arr.last.net_financial_assets.total
    nfi  = filings.re_is_arr.last.net_financing_income.total
    d = 0.0
    dcoc = FinModeling::DebtCostOfCapital.calculate(:after_tax_cost => FinModeling::Rate.new(0.0))
    if (nfa < 0.0) && (nfi < 0.0)
      d = -nfa
      dcoc = FinModeling::DebtCostOfCapital.calculate(:after_tax_cost => FinModeling::Rate.new(nfi / nfa))
    else
    end
    ecoc = FinModeling::FamaFrench::EquityCostOfCapital.from_ticker(args[:stock_symbol])
    wacc = FinModeling::WeightedAvgCostOfCapital.new(equity_market_val      = YahooFinance::get_market_cap(args[:stock_symbol].dup),
                                                     debt_market_val        = d,
                                                     cost_of_equity         = ecoc,
                                                     after_tax_cost_of_debt = dcoc)
    discount_rate = FinModeling::DiscountRate.new(wacc.rate.value + 1.0)
    num_shares = YahooFinance::get_num_shares(args[:stock_symbol].dup)
    valuation = FinModeling::ReOIValuation.new(filings, forecasts, wacc.rate, discount_rate, num_shares)
  
    wacc.summary.print 
    valuation.summary.print
  else
    puts "Oops. Can't do valuation without >= 2 forecasts"
  end
end
