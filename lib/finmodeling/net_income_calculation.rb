module FinModeling
  class NetIncomeCalculation < CompanyFilingCalculation
    include CanCacheClassifications
    include CanCacheSummaries
    include CanClassifyRows

    BASE_FILENAME = File.join(FinModeling::BASE_PATH, "summaries/net_income_")

    ALL_STATES  =             [ :or, :cogs, :oe, :oibt, :fibt, :tax, :ooiat, :fiat ]
    NEXT_STATES = { nil    => [ :or                                                ],
                    :or    => [ :or, :cogs, :oe, :oibt, :fibt                      ],
                    :cogs  => [      :cogs, :oe, :oibt, :fibt, :tax                ],
                    :oe    => [             :oe, :oibt, :fibt, :tax                ],
                    :oibt  => [                  :oibt, :fibt, :tax                ], # obit/fibt can cycle back/forth
                    :fibt  => [                  :obit, :fibt, :tax                ], # obit/fibt can cycle back/forth
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
 
    def has_revenue_item?
      @has_revenue_item ||= leaf_items.any? do |leaf|
        leaf.name.matches_any_regex?([/revenue/i, /sales/i])
      end
    end

    def has_tax_item?
      @has_tax_item ||= leaf_items.any? do |leaf|
        leaf.name.matches_any_regex?([/tax/i])
      end
    end

  end
end
