module FinModeling
  module Mocks
    class Filing
      attr_accessor :term, :date, :link
      def initialize
        @term="10-K"
        @date="1994-01-26T00:00:00-05:00"
        @link="http://www.sec.gov/Archives/edgar/data/320193/000119312512023398/0001193125-12-023398-index.htm"
      end
    end
  
    class Entity
      attr_accessor :name, :filings
      def initialize
        @name = "Apple Inc"
        @filings = []
        @filings.push Mocks::Filing.new
      end
    end
  end
end
