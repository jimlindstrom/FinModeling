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
  end
end
