module FinModeling
  class LiabsAndEquityCalculation < CompanyFilingCalculation
    include CanCacheClassifications
    include CanCacheSummaries
    include CanClassifyRows

    BASE_FILENAME = "summaries/liabs_and_equity_"

    ALL_STATES  =           [ :ol, :fl, :cse ]
    NEXT_STATES = { nil  => [ :ol, :fl, :cse ],
                    :ol  => [ :ol, :fl, :cse ],
                    :fl  => [ :ol, :fl, :cse ],
                    :cse => [      :fl, :cse ] }

    def summary(period)
      summary_cache_key = period.to_pretty_s
      summary = lookup_cached_summary(summary_cache_key)
      return summary if !summary.nil?

      summary = super(period, type_to_flip="debit", flip_total=true)
      if !lookup_cached_classifications(BASE_FILENAME, summary.rows)
        lookahead = [4, summary.rows.length-1].min
        classify_all_rows(ALL_STATES, NEXT_STATES, summary.rows, FinModeling::LiabsAndEquityItem, lookahead)
        save_cached_classifications(BASE_FILENAME, summary.rows)
      end

      save_cached_summary(summary_cache_key, summary)

      return summary
    end

  end
end
