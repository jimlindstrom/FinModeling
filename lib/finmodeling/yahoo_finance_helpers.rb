module YahooFinance
  def YahooFinance.get_market_cap(stock_symbol)
    quote = YahooFinance::get_quotes(YahooFinance::ExtendedQuote, stock_symbol).values.first
    m = /([0-9\.]*)([MB])/.match(quote.marketCap)
    mkt_cap = m[1].to_f
    case
      when m[2]=="M"
        mkt_cap *= 1000*1000
      when m[2]=="B"
        mkt_cap *= 1000*1000*1000
    end
    mkt_cap
  end

  def YahooFinance.get_num_shares(stock_symbol)
    mkt_cap = YahooFinance.get_market_cap(stock_symbol)
    share_price = YahooFinance::get_quotes(YahooFinance::StandardQuote, stock_symbol).values.last.lastTrade.to_f
    mkt_cap / share_price
  end
end
