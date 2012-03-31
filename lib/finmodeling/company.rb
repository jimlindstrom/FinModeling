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
      FileUtils.mkdir_p(File.dirname(filename)) if !File.exists?(File.dirname(filename))
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
      return nil if !File.exists?(filename) || !FinModeling::Config.caching_enabled?
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
  
    BASE_FILENAME = File.join(FinModeling::BASE_PATH, "companies/")
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
      CompanyFilings.new(sorted_reports_of_type("10-K"))
    end
 
    def quarterly_reports
      CompanyFilings.new(sorted_reports_of_type("10-Q"))
    end

    def filings_since_date(start_date)
      reports  = self.annual_reports
      reports += self.quarterly_reports
      reports.select!{ |report| Time.parse(report.date) >= start_date }
      reports.sort!{ |x, y| Time.parse(x.date) <=> Time.parse(y.date) }

      filings = []
      reports.each do |report|
        begin
          case report.term 
            when "10-Q" then filings << FinModeling::QuarterlyReportFiling.download(report.link)
            when "10-K" then filings << FinModeling::AnnualReportFiling.download(   report.link) 
          end
        rescue Exception => e  
          # *ReportFiling.download() will throw errors if it doesn't contain xbrl data.
          puts "Caught error in FinModeling::(.*)ReportFiling.download:"
          puts "\t" + e.message  
          puts "\t" + e.backtrace.inspect.gsub(/, /, "\n\t ")
        end
      end

      return CompanyFilings.new(filings)
    end

    private

    def sorted_reports_of_type(report_type)
      @entity.filings.select{ |x| x.term == report_type }.sort{ |x,y| x.date <=> y.date }
    end

  end
end
