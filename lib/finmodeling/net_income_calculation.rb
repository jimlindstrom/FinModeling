module FinModeling
  class NetIncomeCalculation < CompanyFilingCalculation
    include CanCacheClassifications
    include CanCacheSummaries
    include CanClassifyRows

    BASE_FILENAME = File.join(FinModeling::BASE_PATH, "summaries/net_income_")

    ALL_STATES  =             [ :or, :cogs, :oe, :oibt, :fibt, :tax, :ooiat, :fiat ]
    NEXT_STATES = { nil    => [ :or, :cogs, :oe, :oibt, :fibt, :tax, :ooiat, :fiat ],
                    :or    => [ :or, :cogs, :oe, :oibt, :fibt, :tax, :ooiat, :fiat ],
                    :cogs  => [      :cogs, :oe, :oibt, :fibt, :tax, :ooiat, :fiat ],
                    :oe    => [             :oe, :oibt, :fibt, :tax, :ooiat, :fiat ],
                    :oibt  => [                  :oibt, :fibt, :tax, :ooiat, :fiat ], # obit/fibt can cycle back/forth
                    :fibt  => [                  :obit, :fibt, :tax, :ooiat, :fiat ], # obit/fibt can cycle back/forth
                    :tax   => [                                      :ooiat, :fiat ], # tax can't go to itself. only 1 such item.
                    :ooiat => [                                      :ooiat, :fiat ], # ooiat/fiat can cycle back/forth
                    :fiat  => [                                      :ooiat, :fiat ] }# ooiat/fiat can cycle back/forth

    def summary(args)
      summary_cache_key = args[:period].to_pretty_s
      thesummary = lookup_cached_summary(summary_cache_key)
      return thesummary if !thesummary.nil?
 
      mapping = Xbrlware::ValueMapping.new
      mapping.policy[:debit] = :flip

      thesummary = super(:period => args[:period], :mapping => mapping) # FIXME: flip_total should == true!
      if !lookup_cached_classifications(BASE_FILENAME, thesummary.rows)
        lookahead = [4, thesummary.rows.length-1].min
        classify_rows(ALL_STATES, NEXT_STATES, thesummary.rows, FinModeling::IncomeStatementItem, lookahead)
        save_cached_classifications(BASE_FILENAME, thesummary.rows)
      end

      save_cached_summary(summary_cache_key, thesummary)

      return thesummary
    end
 
  end
end
