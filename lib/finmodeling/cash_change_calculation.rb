module FinModeling

  class CashChangeCalculation < CompanyFilingCalculation
    include CanCacheClassifications
    include CanCacheSummaries
    include CanClassifyRows

    BASE_FILENAME = File.join(FinModeling::BASE_PATH, "summaries/cash_")

    ALL_STATES  =          [ :c, :i, :d, :f ]
    NEXT_STATES = { nil => [ :c             ],
                    :c  => [ :c, :i, :d, :f ],
                    :i  => [     :i, :d, :f ],
                    :d  => [     :i, :d, :f ],
                    :f  => [         :d, :f ] }

    def summary(args)
      summary_cache_key = args[:period].to_pretty_s
      summary = lookup_cached_summary(summary_cache_key)
      return summary if !summary.nil? && false # FIXME: get rid of "and false"

      mapping = Xbrlware::ValueMapping.new
      mapping.policy[:unknown]          = :flip
      mapping.policy[:credit]           = :flip 
      mapping.policy[:debit]            = :no_action 
      mapping.policy[:netincome]        = :no_action 
      mapping.policy[:taxes]            = :no_action
      mapping.policy[:proceedsfromdebt] = :no_action

      find_and_tag_special_items(args)

      summary = super(:period => args[:period], :mapping => mapping)
      if !lookup_cached_classifications(BASE_FILENAME, summary.rows) || true # FIXME: get rid of "or true"
        lookahead = [4, summary.rows.length-1].min
        classify_rows(ALL_STATES, NEXT_STATES, summary.rows, FinModeling::CashChangeItem, lookahead)
        save_cached_classifications(BASE_FILENAME, summary.rows)
      end

      save_cached_summary(summary_cache_key, summary)

      return summary
    end

    private

    def find_and_tag_special_items(args)
      leaf_items(:period => args[:period]).each do |item|
        if item.name.matches_any_regex?([ /NetIncomeLoss/,
                                        /ProfitLoss/ ])
          item.def = {} if !item.def
          item.def["xbrli:balance"] = "netincome"
        end

        if item.name =~ /IncreaseDecreaseInIncomeTaxes/
          item.def = {} if !item.def
          item.def["xbrli:balance"] = "taxes"
        end

        if item.name =~ /ProceedsFromDebtNetOfIssuanceCosts/
          item.def = {} if !item.def
          item.def["xbrli:balance"] = "proceedsfromdebt"
        end
      end
    end

  end
end
