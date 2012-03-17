module FinModeling

  class CashChangeCalculation < CompanyFilingCalculation
    include CanCacheClassifications
    include CanCacheSummaries
    include CanClassifyRows

    #BASE_FILENAME = "summaries/ai_"

    #ALL_STATES  =          [ :oa, :fa ]
    #NEXT_STATES = { nil => [ :oa, :fa ],
    #                :oa => [ :oa, :fa ],
    #                :fa => [ :oa, :fa ] }

    def summary(args)
      #summary_cache_key = period.to_pretty_s
      #summary = lookup_cached_summary(summary_cache_key)
      #return summary if !summary.nil?

      mapping = Xbrlware::ValueMapping.new
      mapping.policy[:unknown]          = :flip
      mapping.policy[:credit]           = :flip 
      mapping.policy[:debit]            = :no_action 
      mapping.policy[:netincome]        = :no_action 
      mapping.policy[:taxes]            = :no_action
      mapping.policy[:proceedsfromdebt] = :no_action

      find_and_tag_special_items(args)

      summary = super(:period => args[:period], :mapping => mapping)
      #if !lookup_cached_classifications(BASE_FILENAME, summary.rows)
      #  lookahead = [4, summary.rows.length-1].min
      #  classify_all_rows(ALL_STATES, NEXT_STATES, summary.rows, FinModeling::AssetsItem, lookahead)
      #  save_cached_classifications(BASE_FILENAME, summary.rows)
      #end

      #save_cached_summary(summary_cache_key, summary)

      return summary
    end

    private

    def find_and_tag_special_items(args)
      leaf_items(:period => args[:period]).each do |item|
        if item.name.matches_regexes?([ /NetIncomeLoss/,
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
