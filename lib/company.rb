module FinModeling
  class Company
    def initialize(entity)
      @entity = entity
    end
  
    def self.find(stock_symbol)
      begin
        entity = SecQuery::Entity.find(stock_symbol, { :relationships => false, 
                                                       :transactions  => false, 
                                                       :filings       => true })
                                                       #:filings       => {:start=> 0, :count=>20, :limit=> 20} })
        return nil if !entity
        return Company.new(entity)
      rescue
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
