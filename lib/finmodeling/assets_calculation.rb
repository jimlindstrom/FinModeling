module FinModeling

  class AssetsCalculation < CompanyFilingCalculation
    include CanCacheClassifications
    include CanCacheSummaries
    include CanClassifyRows

    BASE_FILENAME = File.join(FinModeling::BASE_PATH, "summaries/ai_")

    ALL_STATES  =          [ :oa, :fa ]
    NEXT_STATES = { nil => [ :oa, :fa ],
                    :oa => [ :oa, :fa ],
                    :fa => [ :oa, :fa ] }

    def summary(args)
      summary_cache_key = args[:period].to_pretty_s
      thesummary = lookup_cached_summary(summary_cache_key)
      return thesummary if !thesummary.nil?

      mapping = Xbrlware::ValueMapping.new
      mapping.policy[:credit] = :flip

      thesummary = super(:period => args[:period], :mapping => mapping)
      if !lookup_cached_classifications(BASE_FILENAME, thesummary.rows)
        lookahead = [4, thesummary.rows.length-1].min
        classify_rows(ALL_STATES, NEXT_STATES, thesummary.rows, FinModeling::AssetsItem, lookahead)
        save_cached_classifications(BASE_FILENAME, thesummary.rows)
      end

      save_cached_summary(summary_cache_key, thesummary)

      return thesummary
    end

    def has_cash_item 
      @has_cash_item = leaf_items.any? do |leaf|
        leaf.name.downcase.matches_regexes?([/cash/])
      end
    end

  end
end
