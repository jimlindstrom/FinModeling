module FinModeling
  class Company
    def initialize(entity)
      @entity = entity
    end
  
    def self.find(stock_symbol)
      begin
        entity = SecQuery::Entity.find(stock_symbol, {:relationships=>false, :transactions=>false, :filings=>true})
        return Company.new(entity)
      rescue
        return nil
      end
    end

    def name
      @entity.name
    end
  
    def annual_reports
      @entity.filings.select{ |x| x.term == "10-K" }.sort{ |x,y| x.date <=> y.date }
    end
  end
end
