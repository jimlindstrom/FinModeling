module FinModeling
  class LiabsAndEquityCalculation < CompanyFilingCalculation
    include CanCacheClassifications
    include CanCacheSummaries
    include CanClassifyRows

    BASE_FILENAME = File.join(FinModeling::BASE_PATH, "summaries/liabs_and_equity_")

    ALL_STATES  =           [ :ol, :fl, :cse ]
    NEXT_STATES = { nil  => [ :ol, :fl, :cse ],
                    :ol  => [ :ol, :fl, :cse ],
                    :fl  => [ :ol, :fl, :cse ],
                    :cse => [      :fl, :cse ] }

    def summary(args)
      summary_cache_key = args[:period].to_pretty_s
      summary = lookup_cached_summary(summary_cache_key)
      return summary if !summary.nil?

      mapping = Xbrlware::ValueMapping.new
      mapping.policy[:debit] = :flip

      summary = super(:period => args[:period], :mapping => mapping) # FIXME: flip_total should == true!
      if !lookup_cached_classifications(BASE_FILENAME, summary.rows)
        lookahead = [4, summary.rows.length-1].min
        classify_rows(ALL_STATES, NEXT_STATES, summary.rows, FinModeling::LiabsAndEquityItem, lookahead)
        save_cached_classifications(BASE_FILENAME, summary.rows)
      end

      save_cached_summary(summary_cache_key, summary)

      return summary
    end

  end
end
