module FinModeling
  class ComprehensiveIncomeCalculation < CompanyFilingCalculation
    include CanCacheClassifications
    include CanCacheSummaries
    include CanClassifyRows

    BASE_FILENAME = File.join(FinModeling::BASE_PATH, "summaries/comprehensive_income_")

    ALL_STATES  =                 [ :or, :cogs, :oe, :oibt, :fibt, :tax, :ooiat, :fiat, :ni, :ooci, :ooci_nci, :foci, :unkoci ]
    NEXT_STATES = { nil        => [ :or,                                                :ni                                   ],
                    :or        => [ :or, :cogs, :oe, :oibt, :fibt                                                             ],
                    :cogs      => [      :cogs, :oe, :oibt, :fibt, :tax                                                       ],
                    :oe        => [             :oe, :oibt, :fibt, :tax                                                       ],
                    :oibt      => [                  :oibt, :fibt, :tax                                                       ], # obit/fibt can cycle back/forth
                    :fibt      => [                  :obit, :fibt, :tax                                                       ], # obit/fibt can cycle back/forth
                    :tax       => [                                      :ooiat, :fiat,      :ooci, :ooci_nci, :foci, :unkoci ], # 1 tax item. then moves forward.
                    :ooiat     => [                                      :ooiat, :fiat,      :ooci, :ooci_nci, :foci, :unkoci ], # ooiat/fiat can cycle back/forth
                    :fiat      => [                                      :ooiat, :fiat,      :ooci, :ooci_nci, :foci, :unkoci ], # ooiat/fiat can cycle back/forth

                    :ni        => [                                                          :ooci, :ooci_nci, :foci, :unkoci ], # after ni, no ordering

                    :ooci      => [                                                          :ooci, :ooci_nci, :foci, :unkoci ], # after ni, no ordering
                    :ooci_nci  => [                                                          :ooci, :ooci_nci, :foci, :unkoci ], # after ni, no ordering
                    :foci      => [                                                          :ooci, :ooci_nci, :foci, :unkoci ], # after ni, no ordering
                    :unkoci    => [                                                          :ooci, :ooci_nci, :foci, :unkoci ] }# after ni, no ordering

    def summary(args)
      summary_cache_key = args[:period].to_pretty_s
      thesummary = lookup_cached_summary(summary_cache_key)
      return thesummary if !thesummary.nil?
 
      mapping = Xbrlware::ValueMapping.new
      mapping.policy[:debit] = :flip

      thesummary = super(:period => args[:period], :mapping => mapping)
      if !lookup_cached_classifications(BASE_FILENAME, thesummary.rows)
        lookahead = [4, thesummary.rows.length-1].min
        classify_rows(ALL_STATES, NEXT_STATES, thesummary.rows, FinModeling::ComprehensiveIncomeStatementItem, lookahead)
        save_cached_classifications(BASE_FILENAME, thesummary.rows)
      end

      save_cached_summary(summary_cache_key, thesummary)

      return thesummary
    end
 
    def has_revenue_item?
      @has_revenue_item ||= summary(:period => periods.last).rows.any? do |row|
        row.type == :or
      end
    end

    def has_net_income_item?
      @has_net_income_item ||= summary(:period => periods.last).rows.any? do |row|
        row.type == :ni
      end
    end

  end
end
