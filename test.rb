#!/usr/bin/env ruby

require 'rubygems' # you need this when xbrlware is installed as gem
require 'sec_query'
require 'edgar'
require 'xbrlware'

class Company
  def initialize(entity)
    @entity = entity
    puts "Initializing company: #{@entity.name}"
  end

  def self.find(stock_symbol)
    entity = filings=SecQuery::Entity.find(stock_symbol, {:relationships=>false, :transactions=>false, :filings=>true})
    return Company.new(entity)
  end

  def annual_reports
    @entity.filings.select{ |x| x.term == "10-K" }.sort{ |x,y| x.date <=> y.date }
  end
end

module CanBeWalkedRecursively

  def walk_subtree(elements, indent_count=0)
    elements.each_with_index do |element, index|
      indent=" " * indent_count
  
      output = "#{indent} #{element.label}"
      element.items.each do |item|
        period=item.context.period
        period_str = period.is_duration? ? "#{period.value["start_date"]} to #{period.value["end_date"]}" : "#{period.value}"
        output += " (#{period_str}) = #{item.value}" unless item.nil?
      end
  
      # Print to console
      puts output
  
      # If it has more elements, walk tree, recursively.
      #walk_subtree(element.children, indent_count+1) if element.has_children?
    end
  end

end

class CompanyFiling
  DOWNLOAD_PATH = "filings/"

  def initialize(download_dir)
    instance_file = Xbrlware.file_grep(download_dir)["ins"]
    if instance_file.nil?
      raise "Filing (\"#{download_dir}\") has no instance files. No XBRL filing?"
    end

    @instance = Xbrlware.ins(instance_file)
    @taxonomy = @instance.taxonomy
    @taxonomy.init_all_lb
  end

  def self.download(url)
    download_dir = DOWNLOAD_PATH + url.split("/")[-2]

    if !File.exists?(download_dir)
      dl = Edgar::HTMLFeedDownloader.new()
      dl.download(url, download_dir)
    end

    return self.new(download_dir)
  end

  def print_presentations
    pres = @taxonomy.prelb.presentation
    pres.each do |pre|
      puts "Title is #{pre.title}"
      walk_subtree(pre.arcs)
      puts "\n\n"
    end
  end

  def print_calculations
    calculations=@taxonomy.callb.calculation
    calculations.each do |calc|
      puts "Title is #{calc.title}"
      walk_subtree(calc.arcs)
      puts "\n\n"
    end
  end

  private

  include CanBeWalkedRecursively

end

class CompanyAnnualReportFiling < CompanyFiling
  def balance_sheet
    calculations=@taxonomy.callb.calculation
    bal_sheet = calculations.find{ |x| (x.title.downcase =~ /statement.*financial.*position/) or
                                       (x.title.downcase =~ /balance.*sheet/) }

    return BalanceSheetCalculation.new(@taxonomy, bal_sheet)
  end
end

class CompanyFilingCalculation
  def initialize(taxonomy, calculation)
    @taxonomy = taxonomy
    @calculation = calculation
  end

  def label
    @calculation.label
  end
end

class BalanceSheetCalculation < CompanyFilingCalculation
  def assets
    calc = @calculation.arcs.find{ |x| x.label.downcase.gsub(/[^a-z ]/, '') =~ /(^total *|^)assets$/ }
    return CompanyFilingCalculation.new(@taxonomy, calc)
  end

  def liabs_and_equity
    calc = @calculation.arcs.find{ |x| x.label.downcase.gsub(/[^a-z ]/, '') =~ /(^total *|^)liabilities.*and.*equity/ }
    return CompanyFilingCalculation.new(@taxonomy, calc)
  end
end

company = Company.find(stock_symbol = ARGV[0])
if company.annual_reports.length == 0
  puts "no annual reports"
  exit
end

filing_url = company.annual_reports.last.link
filing = CompanyAnnualReportFiling.download(filing_url)

#filing.print_presentations
#filing.print_calculations

balance_sheet = filing.balance_sheet
if balance_sheet.nil?
  puts "couldn't find balance sheet"
  exit
end

left_side  = balance_sheet.assets
right_side = balance_sheet.liabs_and_equity

if left_side.nil?
  puts "couldn't find assets"
else
  puts "assets label: " + left_side.label
end

if right_side.nil?
  puts "couldn't find liabs/equity"
else
  puts "liabs/equity label: " + right_side.label
end

