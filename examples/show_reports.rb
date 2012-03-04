#!/usr/bin/env ruby

$LOAD_PATH << "."

require 'finmodeling'

def show_usage_and_exit
  puts "usage:"
  puts "\t#{__FILE__} <stock symbol> <10-k|10-q> <0, for most recent|-1 for prevous|-2, etc>"
  puts "\t#{__FILE__} <stock symbol> <start date, e.g. '2010-01-01'>"
  exit
end

def get_args
  args = { :stock_symbol => nil, :filing_urls => nil, :start_date => nil, :report_type => nil, :report_offsets => nil }

  show_usage_and_exit if ARGV.length < 2
  args[:stock_symbol]  = ARGV[0]
  begin
    args[:start_date] = Time.parse(ARGV[1])
  rescue
    show_usage_and_exit if ARGV.length < 3
    args[:report_type]   = case ARGV[1].downcase
      when "10-k"
        :annual_report
      when "10-q"
        :quarterly_report
      else
        show_usage_and_exit
    end
    args[:report_offsets] = ARGV[2..-1].map{ |x| x.to_i }
  end

  return args
end

def get_company_filing_urls(stock_symbol, report_type, report_offsets)
  company = FinModeling::Company.find(stock_symbol)
  raise RuntimeError.new("couldn't find company") if company.nil?
  puts "company name: #{company.name}"

  filing_urls = report_offsets.map do |report_offset|
    case report_type
      when :annual_report
        raise RuntimeError.new("company has no annual reports") if company.annual_reports.length == 0
        company.annual_reports[-1+report_offset].link
      when :quarterly_report
        raise RuntimeError.new("company has no quarterly reports") if company.quarterly_reports.length == 0
        company.quarterly_reports[-1+report_offset].link
    end
  end

  return filing_urls
end

def get_filings(filing_urls, report_type)
  if report_type == :annual_report
    return filings = filing_urls.map do |filing_url|
      FinModeling::AnnualReportFiling.download(filing_url) 
    end
  end

  if report_type == :quarterly_report
    return filings = filing_urls.map do |filing_url|
      FinModeling::QuarterlyReportFiling.download(filing_url) 
    end
  end
end

def get_company_filings_since_date(stock_symbol, start_date)
  company = FinModeling::Company.find(stock_symbol)
  raise RuntimeError.new("couldn't find company") if company.nil?
  puts "company name: #{company.name}"

  reports  = company.annual_reports.select{ |report| Time.parse(report.date) >= start_date } 
  reports += company.quarterly_reports.select{ |report| Time.parse(report.date) >= start_date }
  reports.sort!{ |x, y| Time.parse(x.date) <=> Time.parse(y.date) }

  filings = reports.map do |report|
    if report.term == "10-Q"
      FinModeling::QuarterlyReportFiling.download(report.link) 
    else
      FinModeling::AnnualReportFiling.download(report.link)
    end
  end

  return filings
end

def next_balance_sheet_analysis(prev_analysis, prev_filing, filing)
  if !prev_filing.nil?
    prev_period = prev_filing.balance_sheet.periods.last
    prev_reformed_bal_sheet = prev_filing.balance_sheet.reformulated(prev_period)
  end

  period = filing.balance_sheet.periods.last
  reformed_bal_sheet = filing.balance_sheet.reformulated(period)

  analysis = FinModeling::CalculationSummary.new
  analysis.title = ""
  analysis.header_row = { :key => "", :val => period.to_pretty_s }
  analysis.rows = []
  analysis.rows.push(  { :key => "NOA (000's)",       :val => (reformed_bal_sheet.net_operating_assets.total/1000.0).round.to_f })
  analysis.rows.push(  { :key => "NFA (000's)",       :val => (reformed_bal_sheet.net_financial_assets.total/1000.0).round.to_f })
  analysis.rows.push(  { :key => "CSE (000's)",       :val => (reformed_bal_sheet.common_shareholders_equity.total/1000.0).round.to_f })
  analysis.rows.push(  { :key => "Composition Ratio", :val => reformed_bal_sheet.composition_ratio })
  if prev_filing.nil?
    analysis.rows.push({ :key => "NOA Growth",        :val => 0 })
    analysis.rows.push({ :key => "CSE Growth",        :val => 0 })
  else
    analysis.rows.push({ :key => "NOA Growth",        :val => reformed_bal_sheet.noa_growth(prev_reformed_bal_sheet) })
    analysis.rows.push({ :key => "CSE Growth",        :val => reformed_bal_sheet.cse_growth(prev_reformed_bal_sheet) })
  end

  return (prev_analysis + analysis) if !prev_analysis.nil?
  return (                analysis) if  prev_analysis.nil?
end

def get_balance_sheet_analysis(filings)
  prev_filing = nil
  analysis    = nil

  filings.each do |filing|
    analysis    = next_balance_sheet_analysis(analysis, prev_filing, filing)
    prev_filing = filing
  end

  analysis.totals_row_enabled = false

  return analysis
end

def next_income_statement_analysis(prev_analysis, prev_filing, filing)
  if !prev_filing.nil?
    prev_is_period = case prev_filing
      when FinModeling::AnnualReportFiling
        prev_filing.income_statement.net_income_calculation.periods.yearly.last
      when FinModeling::QuarterlyReportFiling
        prev_filing.income_statement.net_income_calculation.periods.quarterly.last
    end
    prev_reformed_inc_stmt = prev_filing.income_statement.reformulated(prev_is_period)

    prev_bs_period = prev_filing.balance_sheet.periods.last
    prev_reformed_bal_sheet = prev_filing.balance_sheet.reformulated(prev_bs_period)
  end

  is_period = case filing
    when FinModeling::AnnualReportFiling
      filing.income_statement.net_income_calculation.periods.yearly.last
    when FinModeling::QuarterlyReportFiling
      filing.income_statement.net_income_calculation.periods.quarterly.last
  end
  reformed_inc_stmt = filing.income_statement.reformulated(is_period)

  bs_period = filing.balance_sheet.periods.last
  reformed_bal_sheet = filing.balance_sheet.reformulated(bs_period)

  analysis = FinModeling::CalculationSummary.new
  analysis.title = ""
  analysis.header_row = { :key => "", :val => bs_period.to_pretty_s }
  analysis.rows = []
  analysis.rows.push(  { :key => "Gross Margin",   :val => reformed_inc_stmt.gross_margin })
  analysis.rows.push(  { :key => "Sales PM",       :val => reformed_inc_stmt.sales_profit_margin })
  analysis.rows.push(  { :key => "Operating PM",   :val => reformed_inc_stmt.operating_profit_margin })
  analysis.rows.push(  { :key => "FI / Sales",     :val => reformed_inc_stmt.fi_over_sales })
  analysis.rows.push(  { :key => "NI / Sales",     :val => reformed_inc_stmt.ni_over_sales })
  if !prev_filing.nil?
    analysis.rows.push({ :key => "Sales / NOA",    :val => reformed_inc_stmt.sales_over_noa(prev_reformed_bal_sheet) })
    analysis.rows.push({ :key => "FI / NFA",       :val => reformed_inc_stmt.fi_over_nfa(prev_reformed_bal_sheet) })
    analysis.rows.push({ :key => "Revenue Growth", :val => reformed_inc_stmt.revenue_growth(prev_reformed_inc_stmt) })
    analysis.rows.push({ :key => "Core OI Growth", :val => reformed_inc_stmt.core_oi_growth(prev_reformed_inc_stmt) })
    analysis.rows.push({ :key => "OI Growth",      :val => reformed_inc_stmt.oi_growth(prev_reformed_inc_stmt) })
    analysis.rows.push({ :key => "ReOI (000's)",   :val => (reformed_inc_stmt.re_oi(prev_reformed_bal_sheet)/1000.0).round.to_f })
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

def get_income_statement_analysis(filings)
  prev_filing = nil
  analysis    = nil

  filings.each do |filing|
    analysis    = next_income_statement_analysis(analysis, prev_filing, filing)
    prev_filing = filing
  end

  analysis.totals_row_enabled = false

  return analysis
end


args = get_args
filings = nil
if !args[:start_date].nil?
  filings = get_company_filings_since_date(args[:stock_symbol], args[:start_date])
else
  args[:filing_urls] = get_company_filing_urls(args[:stock_symbol], args[:report_type], args[:report_offsets])
  filings = get_filings(args[:filing_urls], args[:report_type])
end

get_balance_sheet_analysis(   filings).print
get_income_statement_analysis(filings).print

