#!/usr/bin/env ruby

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
if filings.empty?
  puts "No filings..."
  exit
end

disclosure_periods = {}

filings.each do |filing|

  filing.disclosures.each do |disclosure|
    disclosure_label = disclosure.summary(:period => disclosure.periods.last).title.gsub(/ \(.*/,'')

    disclosure_periods[disclosure_label] ||= []
    disclosure_periods[disclosure_label] += disclosure.periods
  end
end

disclosure_periods.keys.sort.each do |disclosure_label|
  puts disclosure_label.to_s + ": " + disclosure_periods[disclosure_label].map{ |x| x.to_pretty_s }.sort.uniq.join(', ')
end

