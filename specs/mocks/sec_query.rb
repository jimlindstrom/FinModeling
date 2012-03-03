module FinModeling
  module Mocks
    class Filing_10K
      attr_accessor :term, :date, :link
      def initialize
        @term="10-K"
        @date="1994-01-26T00:00:00-05:00"
        @link="http://www.sec.gov/Archives/edgar/data/320193/000119312512023398/0001193125-12-023398-index.htm"
      end
    end

    class Filing_10Q
      attr_accessor :term, :date, :link
      def initialize
        @term="10-Q"
        @date="1995-01-26T00:00:00-05:00"
        @link="http://www.sec.gov/Archives/edgar/data/1288776/000119312511282235/0001193125-11-282235-index.htm"
      end
    end
  
    class Entity
      attr_accessor :name, :filings
      def initialize
        @name = "Apple Inc"
        @filings = []
        @filings.push Mocks::Filing_10K.new
        @filings.push Mocks::Filing_10Q.new
      end
    end
  end
end
