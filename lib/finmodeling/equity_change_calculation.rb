module FinModeling

  class EquityChangeCalculation < CompanyFilingCalculation
    include CanCacheClassifications
    include CanCacheSummaries
    include CanClassifyRows

    BASE_FILENAME = File.join(FinModeling::BASE_PATH, "summaries/equity_change_")

    ALL_STATES = [ :share_issue, :share_repurch, :minority_int, :common_div, :net_income, :oci, :preferred_div ]       
    NEXT_STATES = { nil            => [ :share_issue, :share_repurch, :minority_int, :common_div, :net_income, :oci, :preferred_div ],
                    :share_issue   => [ :share_issue, :share_repurch, :minority_int, :common_div, :net_income, :oci, :preferred_div ],
                    :share_repurch => [ :share_issue, :share_repurch, :minority_int, :common_div, :net_income, :oci, :preferred_div ],
                    :minority_int  => [ :share_issue, :share_repurch, :minority_int, :common_div, :net_income, :oci, :preferred_div ],
                    :common_div    => [ :share_issue, :share_repurch, :minority_int, :common_div, :net_income, :oci, :preferred_div ],
                    :net_income    => [ :share_issue, :share_repurch, :minority_int, :common_div, :net_income, :oci, :preferred_div ],
                    :oci           => [ :share_issue, :share_repurch, :minority_int, :common_div, :net_income, :oci, :preferred_div ],
                    :preferred_div => [ :share_issue, :share_repurch, :minority_int, :common_div, :net_income, :oci, :preferred_div ] }

    def summary(args)
      summary_cache_key = args[:period].to_pretty_s
      summary = lookup_cached_summary(summary_cache_key)
      return summary if !summary.nil? && false # FIXME: get rid of "and false"

      mapping = Xbrlware::ValueMapping.new
      mapping.policy[:unknown]          = :no_action
      mapping.policy[:credit]           = :no_action
      mapping.policy[:debit]            = :flip

      summary = super(:period => args[:period], :mapping => mapping)
      if !lookup_cached_classifications(BASE_FILENAME, summary.rows) or true # FIXME: get rid of "or true"
        lookahead = [2, summary.rows.length-1].min
        classify_rows(ALL_STATES, NEXT_STATES, summary.rows, FinModeling::EquityChangeItem, lookahead)
        save_cached_classifications(BASE_FILENAME, summary.rows)
      end

      save_cached_summary(summary_cache_key, summary)

      return summary
    end

  end
end
