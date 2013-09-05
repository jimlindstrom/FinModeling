module FinModeling

  module CAPM
    # References:
    # 1. http://business.baylor.edu/don_cunningham/How_Firms_Estimate_Cost_of_Capital_(2011).pdf
    #    "Current Trends in Estimating and Applying the Cost of Capital" (2011)
    # 2. http://pages.stern.nyu.edu/~adamodar/pdfiles/valn2ed/ch8.pdf
    #    "Estimating Risk Parameters and Costs of Financing"
    # 3. http://www.cb.wsu.edu/~nwalcott/finance425/Readings/BRUNEREst_Cost_of_Capital.pdf
    #    "Best Practices in Estimating the Cost of Capital: Survey and Synthesis" (1998)
    # 4. http://www.nek.lu.se/NEKAVI/Cost%20of%20Capital%20slides.pdf
    #    "Estimating Cost of Capital" (2009)

    MARKET_PREMIUM = 0.055 # FIXME: this is totally arbitrary. Find a better way to represent the fact that this is a probability distribution

    class RiskFreeRate
      # Possible symbols:
      # "^TNX"  -> CBOEInterestRate10-YearT-Note (Good for long-term, future-oriented decisions)
      # ?       -> 90-day t-bill                 (Good for historical short-period R_f estimation)
      def self.forward_estimate(risk_free_symbol="^TNX")
        quotes = YahooFinance::get_HistoricalQuotes_days(URI::encode(risk_free_symbol), num_days=1)
        FinModeling::Rate.new(quotes.last.adjClose / 100.0)
      end
    end

    class Beta
      # Possible index tickers:
      # "Spy"   -> S&P 500
      # "^IXIC" -> Nasdaq
      def self.from_ticker(company_ticker, num_days=6*365, index_ticker="SPY")
        index_quotes   = FamaFrench::EquityHistoricalData.new(index_ticker,   num_days)
        company_quotes = FamaFrench::EquityHistoricalData.new(company_ticker, num_days)
  
        raise "no index returns"   if !index_quotes   || index_quotes.none?
        raise "no company returns" if !company_quotes || company_quotes.none?

        common_dates = index_quotes  .year_and_month_strings &
                       company_quotes.year_and_month_strings

        index_quotes  .filter_by_date!(common_dates)
        company_quotes.filter_by_date!(common_dates)
 
        raise "no index returns (after filtering)"   if !index_quotes   || index_quotes.none?
        raise "no company returns (after filtering)" if !company_quotes || company_quotes.none?
 
        index_div_hist   = NasdaqQuery::DividendHistory.for_symbol(index_ticker)
        company_div_hist = NasdaqQuery::DividendHistory.for_symbol(company_ticker)
   
        index_monthly_returns   = index_quotes  .monthly_returns(index_div_hist)
        company_monthly_returns = company_quotes.monthly_returns(company_div_hist)

        raise "no monthly index returns"   if !index_monthly_returns || index_monthly_returns.none?
        raise "no monthly company returns" if !company_monthly_returns || company_monthly_returns.none?
  
        x = GSL::Vector.alloc(index_monthly_returns)
        y = GSL::Vector.alloc(company_monthly_returns)
        intercept, slope, cov00, cov01, cov11, chisq, status = GSL::Fit::linear(x, y)
  
        # FIXME: evaluate [intercept - Rf*(1-beta)]. It tells how much better/worse than expected (given its risk) the stock did. [per time period]

        # FIXME: subtracting/adding one standard error of the beta gives a 95% confidence interval. That could be used to give a confidence interval
        #        for the resulting valuation.

        beta = slope
      end
    end

    class AdjustedBeta # see: http://financetrain.com/adjusted-and-unadjusted-beta/
      MEAN_LONG_TERM_BETA = 1.0
      def self.from_beta(raw_beta)
        ((2.0*raw_beta) + (1.0*MEAN_LONG_TERM_BETA)) / 3.0
      end
    end

    class EquityCostOfCapital
      def self.from_beta(beta)
        Rate.new(RiskFreeRate.forward_estimate.value + (beta * MARKET_PREMIUM))
      end

      def self.from_ticker(company_ticker)
        raw_beta = Beta.from_ticker(company_ticker)
        puts "CAPM::EquityCostOfCapital -> raw beta = #{raw_beta}"
        adj_beta = AdjustedBeta.from_beta(raw_beta)
        puts "CAPM::EquityCostOfCapital -> adj beta = #{adj_beta}"
        self.from_beta(adj_beta)
      end
    end
  end
end
