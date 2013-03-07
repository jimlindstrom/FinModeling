module FinModeling

  module CanCacheSummaries
    protected

    def lookup_cached_summary(key)
      @summary_cache = { } if @summary_cache.nil?
      return @summary_cache[key]
    end

    def save_cached_summary(key, summary)
      @summary_cache[key] = summary
    end
  end

end
