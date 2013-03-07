require 'spec_helper'

describe FinModeling::CompanyBeta do
  describe "#from_ticker" do
    it "returns the right value" do
      index_ticker = "SPY"
      mock_index_quotes   = []
      mock_index_quotes   << YahooFinance::HistoricalQuote.new("SPY", ["2013-02-05",153.66,154.7,153.64,154.29,121431900, 54.29])
      mock_index_quotes   << YahooFinance::HistoricalQuote.new("SPY", ["2013-02-06",153.66,154.7,153.64,154.29,121431900, 52.29])
      mock_index_quotes   << YahooFinance::HistoricalQuote.new("SPY", ["2013-02-07",153.66,154.7,153.64,154.29,121431900, 58.29])
      mock_index_quotes   << YahooFinance::HistoricalQuote.new("SPY", ["2013-02-08",153.66,154.7,153.64,154.29,121431900, 57.29])
      mock_index_quotes   << YahooFinance::HistoricalQuote.new("SPY", ["2013-02-09",153.66,154.7,153.64,154.29,121431900, 84.29])
      mock_index_quotes   << YahooFinance::HistoricalQuote.new("SPY", ["2013-02-10",153.66,154.7,153.64,154.29,121431900, 73.29])
      mock_index_quotes   << YahooFinance::HistoricalQuote.new("SPY", ["2013-02-11",153.66,154.7,153.64,154.29,121431900, 64.29])
      mock_index_quotes   << YahooFinance::HistoricalQuote.new("SPY", ["2013-02-12",153.66,154.7,153.64,154.29,121431900, 54.29])
      mock_index_quotes   << YahooFinance::HistoricalQuote.new("SPY", ["2013-02-13",153.66,154.7,153.64,154.29,121431900, 61.29])
      mock_index_quotes   << YahooFinance::HistoricalQuote.new("SPY", ["2013-02-14",153.66,154.7,153.64,154.29,121431900, 44.29])
  
      company_ticker = "AAPL"
      mock_company_quotes = []
      mock_company_quotes << YahooFinance::HistoricalQuote.new("AAPL",["2013-02-05",153.66,154.7,153.64,154.29,121431900,154.29])
      mock_company_quotes << YahooFinance::HistoricalQuote.new("AAPL",["2013-02-06",153.66,154.7,153.64,154.29,121431900,152.29])
      mock_company_quotes << YahooFinance::HistoricalQuote.new("AAPL",["2013-02-07",153.66,154.7,153.64,154.29,121431900,158.29])
      mock_company_quotes << YahooFinance::HistoricalQuote.new("AAPL",["2013-02-08",153.66,154.7,153.64,154.29,121431900,157.29])
      mock_company_quotes << YahooFinance::HistoricalQuote.new("AAPL",["2013-02-09",153.66,154.7,153.64,154.29,121431900,184.29])
      mock_company_quotes << YahooFinance::HistoricalQuote.new("AAPL",["2013-02-10",153.66,154.7,153.64,154.29,121431900,173.29])
      mock_company_quotes << YahooFinance::HistoricalQuote.new("AAPL",["2013-02-11",153.66,154.7,153.64,154.29,121431900,164.29])
      mock_company_quotes << YahooFinance::HistoricalQuote.new("AAPL",["2013-02-12",153.66,154.7,153.64,154.29,121431900,154.29])
      mock_company_quotes << YahooFinance::HistoricalQuote.new("AAPL",["2013-02-13",153.66,154.7,153.64,154.29,121431900,161.29])
      mock_company_quotes << YahooFinance::HistoricalQuote.new("AAPL",["2013-02-14",153.66,154.7,153.64,154.29,121431900,144.29])
  
      num_days = 10
  
      YahooFinance.should_receive(:get_HistoricalQuotes_days).with(index_ticker,   num_days).and_return(mock_index_quotes)
      YahooFinance.should_receive(:get_HistoricalQuotes_days).with(company_ticker, num_days).and_return(mock_company_quotes)
  
      common_dates = mock_index_quotes.map{ |x| x.date } & mock_company_quotes.map{ |x| x.date }
  
      index_quotes   = mock_index_quotes  .select{ |x| common_dates.include?(x.date) }.sort{ |x,y| x.date <=> y.date }
      company_quotes = mock_company_quotes.select{ |x| common_dates.include?(x.date) }.sort{ |x,y| x.date <=> y.date }
  
      index_daily_change   = index_quotes.each_cons(2).map  { |pair| (pair[1].adjClose-pair[0].adjClose)/pair[0].adjClose }
      company_daily_change = company_quotes.each_cons(2).map{ |pair| (pair[1].adjClose-pair[0].adjClose)/pair[0].adjClose }
  
      x = GSL::Vector.alloc(index_daily_change)
      y = GSL::Vector.alloc(company_daily_change)
      intercept, slope = GSL::Fit::linear(x, y)
      expected_beta = slope
  
      FinModeling::CompanyBeta.from_ticker(company_ticker, num_days).should be_within(0.1).of(expected_beta)
    end
  end
end
