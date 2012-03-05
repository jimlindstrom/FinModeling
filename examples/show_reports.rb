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

  filings = []
  reports.each do |report|
    begin
      filing = FinModeling::QuarterlyReportFiling.download(report.link) if report.term == "10-Q"
      filing = FinModeling::AnnualReportFiling.download(   report.link) if report.term == "10-K"
      filings.push filing if !filing.nil?
    rescue
      # *ReportFiling.download() will throw errors if it doesn't contain xbrl data.
    end
  end

  return filings
end

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
    analysis.rows.push({ :key => "CSE Growth",        :val =>  re_bs.cse_growth(prev_re_bs) })
  end

  return (prev_analysis + analysis) if !prev_analysis.nil?
  return (                analysis) if  prev_analysis.nil?
end

def get_balance_sheet_analysis(filings)
  prev_re_bs   = nil
  analysis     = nil

  filings.each do |filing|
    period     = filing.balance_sheet.periods.last
    re_bs      = filing.balance_sheet.reformulated(period)

    analysis   = next_balance_sheet_analysis(analysis, prev_re_bs, re_bs)
    prev_re_bs = re_bs
  end

  analysis.totals_row_enabled = false

  return analysis
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

def get_income_statement_analysis(filings)
  analysis    = nil
  prev_re_bs  = nil
  prev_re_is  = nil

  filings.each do |filing|
    is_period  = case filing.class.to_s
      when "FinModeling::AnnualReportFiling"    then filing.income_statement.net_income_calculation.periods.yearly.last
      when "FinModeling::QuarterlyReportFiling" then filing.income_statement.net_income_calculation.periods.quarterly.last
    end
    re_is      = filing.income_statement.reformulated(is_period)
  
    bs_period  = filing.balance_sheet.periods.last
    re_bs      = filing.balance_sheet.reformulated(bs_period)

    analysis   = next_income_statement_analysis(analysis, prev_re_bs, prev_re_is, re_bs, re_is)

    prev_re_bs = re_bs
    prev_re_is = re_is
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

