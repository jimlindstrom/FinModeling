module SecQuery
  class Filing
    def write_constructor(file, item)
      file.puts "filing = { :cik => \"#{@cik}\", :title => \"#{@title}\", :summary => \"#{@summary}\", " + 
                ":link => \"#{@link.gsub(/"/, "\\\"")}\", :term => \"#{@term}\", :date => \"#{@date}\", :file_id => \"#{@file_id}\" }"
      file.puts "#{item} = SecQuery::Filing.new(filing)"
    end
  end
  class Entity
    def write_constructor(filename)
      file = File.open(filename, "w")
      filing_names = []
      @filings.select{ |x| x.title =~ /^10-/ }.each_with_index do |filing, index|
        filing_name = "item_#{index}"
        filing.write_constructor(file, filing_name)
        filing_names.push filing_name
      end
      file.puts "@entity = SecQuery::Entity.new({ :name => \"#{@name.gsub(/"/, "\\\"")}\", :filings => [#{filing_names.join(',')}] })"
      file.close
    end

    def self.load(filename)
      return nil if !File.exists?(filename)
      eval(File.read(filename))
      return @entity
    end
  end
end

module FinModeling
  class Company
    def initialize(entity)
      @entity = entity
    end
  
    BASE_FILENAME = "companies/"
    def self.find(stock_symbol)
      filename = BASE_FILENAME + stock_symbol.upcase + ".rb"
      entity = SecQuery::Entity.load(filename)
      return Company.new(entity) if !entity.nil?
      begin
        entity = SecQuery::Entity.find(stock_symbol, { :relationships => false, 
                                                       :transactions  => false, 
                                                       :filings       => true })
                                                       #:filings       => {:start=> 0, :count=>20, :limit=> 20} })
        return nil if !entity
        entity.write_constructor(filename)
        return Company.new(entity)
      rescue Exception => e
        puts "Warning: failed to load entity"
        puts "\t" + e.message
        puts "\t" + e.backtrace.inspect.gsub(/, /, "\n\t ")
        return nil
      end
    end

    def name
      @entity.name.gsub(/ \(.*/, '')
    end
   
    def annual_reports
      @entity.filings.select{ |x| x.term == "10-K" }.sort{ |x,y| x.date <=> y.date }
    end
 
    def quarterly_reports
      @entity.filings.select{ |x| x.term == "10-Q" }.sort{ |x,y| x.date <=> y.date }
    end

    def filings_since_date(start_date)
      reports  = self.annual_reports.select{ |report| Time.parse(report.date) >= start_date }
      reports += self.quarterly_reports.select{ |report| Time.parse(report.date) >= start_date }
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
  end
end
