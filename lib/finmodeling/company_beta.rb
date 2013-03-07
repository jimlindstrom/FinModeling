module FinModeling
  # this is a very simplistic implementation. It doesn't use the CAPM formula, and is just a simple
  # regression of (daily) market returns against company returns.
  class CompanyBeta
    # Possible index tickers:
    # "Spy" -> S&P 500
    # "^IXIC" -> Nasdaq
    def self.from_ticker(company_ticker, num_days=2*365, index_ticker="SPY", risk_free_ticker="^TNX")
      index_quotes   = YahooFinance::get_HistoricalQuotes_days(URI::encode(index_ticker),     num_days)
      company_quotes = YahooFinance::get_HistoricalQuotes_days(URI::encode(company_ticker),   num_days)

      common_dates = index_quotes  .map{ |x| x.date } &
                     company_quotes.map{ |x| x.date }

      index_quotes   = index_quotes  .select{ |x| common_dates.include?(x.date) }.sort{ |x,y| x.date <=> y.date }
      company_quotes = company_quotes.select{ |x| common_dates.include?(x.date) }.sort{ |x,y| x.date <=> y.date }

      index_daily_change   = index_quotes.each_cons(2).map    { |pair| (pair[1].adjClose-pair[0].adjClose)/pair[0].adjClose }
      company_daily_change = company_quotes.each_cons(2).map  { |pair| (pair[1].adjClose-pair[0].adjClose)/pair[0].adjClose }

      x = GSL::Vector.alloc(index_daily_change)
      y = GSL::Vector.alloc(company_daily_change)
      intercept, slope, cov00, cov01, cov11, chisq, status = GSL::Fit::linear(x, y)

      beta = slope
    end
  end
end
