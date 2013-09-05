require 'spec_helper'
require 'date' # FIXME: stuff this somewhere else?

describe FinModeling::CAPM::Beta do
  describe "#from_ticker" do
    context "when num_days >= 31" do
      it "returns the right value" do
        index_ticker = "SPY"
        mock_index_quotes   = []
        company_ticker = "AAPL"
        mock_company_quotes = []
  
        num_days = 90 # FIXME: must be greater than 30?
        0.upto(num_days-1) do |day|
          date_str = (DateTime.new(2013, 2, 5) + day).strftime("%Y-%m-%d")
          mock_index_quotes   << YahooFinance::HistoricalQuote.new(index_ticker,   [date_str,153.6,154.7,153.6,154.2,121431900, 54.29 + day + rand])
          mock_company_quotes << YahooFinance::HistoricalQuote.new(company_ticker, [date_str,153.6,154.7,153.6,154.2,121431900,154.29 + day + rand])
        end
    
        YahooFinance.should_receive(:get_HistoricalQuotes_days).with(index_ticker,   num_days).and_return(mock_index_quotes)
        YahooFinance.should_receive(:get_HistoricalQuotes_days).with(company_ticker, num_days).and_return(mock_company_quotes)
    
        common_dates = mock_index_quotes.map{ |x| x.date } & mock_company_quotes.map{ |x| x.date }
    
        index_daily_quotes   = mock_index_quotes  .select{ |x| common_dates.include?(x.date) }.sort{ |x,y| x.date <=> y.date }
        company_daily_quotes = mock_company_quotes.select{ |x| common_dates.include?(x.date) }.sort{ |x,y| x.date <=> y.date }
  
        index_monthly_quotes   = index_daily_quotes  .group_by{ |x| x.date.gsub(/-[0-9][0-9]$/, "") }
                                                     .values
                                                     .map{ |x| x.sort{ |x,y| x.date <=> y.date }.first }
                                                     .sort{ |x,y| x.date <=> y.date }[1..-1]
        company_monthly_quotes = company_daily_quotes.group_by{ |x| x.date.gsub(/-[0-9][0-9]$/, "") }
                                                     .values
                                                     .map{ |x| x.sort{ |x,y| x.date <=> y.date }.first }
                                                     .sort{ |x,y| x.date <=> y.date }[1..-1]
   
        index_monthly_returns   = index_monthly_quotes.each_cons(2).map  { |pair| (pair[1].adjClose-pair[0].adjClose)/pair[0].adjClose }
        company_monthly_returns = company_monthly_quotes.each_cons(2).map{ |pair| (pair[1].adjClose-pair[0].adjClose)/pair[0].adjClose }
    
        x = GSL::Vector.alloc(index_monthly_returns)
        y = GSL::Vector.alloc(company_monthly_returns)
        intercept, slope = GSL::Fit::linear(x, y)
        expected_beta = slope
    
        FinModeling::CAPM::Beta.from_ticker(company_ticker, num_days).should be_within(0.1).of(expected_beta) # FIXME: this is now ignorant of dividends...
      end
    end
  end
end
