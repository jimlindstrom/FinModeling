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

class Filings < Array
  def balance_sheet_analysis
    prev_re_bs   = nil
    analysis     = nil
  
    self.each do |filing|
      period     = filing.balance_sheet.periods.last
      re_bs      = filing.balance_sheet.reformulated(period)
  
      analysis   = next_balance_sheet_analysis(analysis, prev_re_bs, re_bs)
      prev_re_bs = re_bs
    end
  
    analysis.totals_row_enabled = false
  
    return analysis
  end

  def income_statement_analysis
    analysis    = nil
    prev_re_bs  = nil
    prev_re_is  = nil
    prev_filing = nil
  
    self.each do |filing|
      is_period   = case filing.class.to_s
        when "FinModeling::AnnualReportFiling"    then filing.income_statement.net_income_calculation.periods.yearly.last
        when "FinModeling::QuarterlyReportFiling" then filing.income_statement.net_income_calculation.periods.quarterly.last
      end
      re_is       = filing.income_statement.reformulated(is_period)
      if filing.class.to_s == "FinModeling::AnnualReportFiling"
        begin
          period_1q_thru_3q = prev_filing.income_statement.net_income_calculation.periods.threequarterly.last
          prev3q  = prev_filing.income_statement.reformulated(period_1q_thru_3q)
          re_is   = re_is - prev3q
        rescue
          puts "Warning: failed to turn an Annual Report (#{is_period.to_pretty_s}) into a Quarterly Report..."
        end
      end
    
      bs_period   = filing.balance_sheet.periods.last
      re_bs       = filing.balance_sheet.reformulated(bs_period)
  
      analysis    = next_income_statement_analysis(analysis, prev_re_bs, prev_re_is, re_bs, re_is)
  
      prev_re_bs  = re_bs
      prev_re_is  = re_is
      prev_filing = filing
    end
  
    analysis.totals_row_enabled = false
  
    return analysis
  end

  private

  def next_balance_sheet_analysis(prev_analysis, prev_re_bs, re_bs)
    analysis = FinModeling::CalculationSummary.new
  
    analysis.title = ""
    analysis.header_row= { :key => "",                  :val =>  re_bs.period.to_pretty_s }
  
    analysis.rows = []
    analysis.rows.push(  { :key => "NOA (000's)",       :val => (re_bs.net_operating_assets.total/      1000.0).round.to_f })
    analysis.rows.push(  { :key => "NFA (000's)",       :val => (re_bs.net_financial_assets.total/      1000.0).round.to_f })
    analysis.rows.push(  { :key => "CSE (000's)",       :val => (re_bs.common_shareholders_equity.total/1000.0).round.to_f })
    analysis.rows.push(  { :key => "Composition Ratio", :val =>  re_bs.composition_ratio })
    if prev_re_bs.nil?
      analysis.rows.push({ :key => "NOA Growth",        :val =>  0 })
      analysis.rows.push({ :key => "CSE Growth",        :val =>  0 })
    else
      analysis.rows.push({ :key => "NOA Growth",        :val =>  re_bs.noa_growth(prev_re_bs) })
      analysis.rows.push({ :key => "CSE Growth",        :val =>  re_bs.cse_growth(prev_re_bs) }) # this is too high on NFLX's 2011 10K
    end
  
    return (prev_analysis + analysis) if !prev_analysis.nil?
    return (                analysis) if  prev_analysis.nil?
  end
  
  def next_income_statement_analysis(prev_analysis, prev_re_bs, prev_re_is, re_bs, re_is)
    analysis = FinModeling::CalculationSummary.new
  
    analysis.title = ""
    analysis.header_row= { :key => "",               :val => re_bs.period.to_pretty_s }
  
    analysis.rows = []
    analysis.rows.push(  { :key => "Revenue (000's)",:val => (re_is.operating_revenues.total/         1000.0).round.to_f })
    analysis.rows.push(  { :key => "Core OI (000's)",:val => (re_is.income_from_sales_after_tax.total/1000.0).round.to_f })
    analysis.rows.push(  { :key => "OI (000's)",     :val => (re_is.operating_income_after_tax.total/ 1000.0).round.to_f })
    analysis.rows.push(  { :key => "FI (000's)",     :val => (re_is.net_financing_income.total/       1000.0).round.to_f })
    analysis.rows.push(  { :key => "NI (000's)",     :val => (re_is.comprehensive_income.total/       1000.0).round.to_f })
    analysis.rows.push(  { :key => "Gross Margin",   :val =>  re_is.gross_margin })
    analysis.rows.push(  { :key => "Sales PM",       :val =>  re_is.sales_profit_margin })
    analysis.rows.push(  { :key => "Operating PM",   :val =>  re_is.operating_profit_margin })
    analysis.rows.push(  { :key => "FI / Sales",     :val =>  re_is.fi_over_sales })
    analysis.rows.push(  { :key => "NI / Sales",     :val =>  re_is.ni_over_sales })
  
    if !prev_re_bs.nil? && !prev_re_is.nil?
      analysis.rows.push({ :key => "Sales / NOA",    :val =>  re_is.sales_over_noa(prev_re_bs) })
      analysis.rows.push({ :key => "FI / NFA",       :val =>  re_is.fi_over_nfa(   prev_re_bs) })
      analysis.rows.push({ :key => "Revenue Growth", :val =>  re_is.revenue_growth(prev_re_is) })
      analysis.rows.push({ :key => "Core OI Growth", :val =>  re_is.core_oi_growth(prev_re_is) })
      analysis.rows.push({ :key => "OI Growth",      :val =>  re_is.oi_growth(     prev_re_is) })
      analysis.rows.push({ :key => "ReOI (000's)",   :val => (re_is.re_oi(         prev_re_bs)/1000.0).round.to_f })
    else  
      analysis.rows.push({ :key => "Sales / NOA",    :val => 0 })
      analysis.rows.push({ :key => "FI / NFA",       :val => 0 })
      analysis.rows.push({ :key => "Revenue Growth", :val => 0 })
      analysis.rows.push({ :key => "Core OI Growth", :val => 0 })
      analysis.rows.push({ :key => "OI Growth",      :val => 0 })
      analysis.rows.push({ :key => "ReOI (000's)",   :val => 0 })
    end
  
    return (prev_analysis + analysis) if !prev_analysis.nil?
    return (                analysis) if  prev_analysis.nil?
  end
end


args = Arguments.parse(ARGV)

company = FinModeling::Company.find(args[:stock_symbol])
raise RuntimeError.new("couldn't find company") if company.nil?
puts "company name: #{company.name}"

filings = Filings.new(company.filings_since_date(args[:start_date]))

filings.balance_sheet_analysis.print
filings.income_statement_analysis.print

