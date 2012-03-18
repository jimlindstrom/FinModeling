module FinModeling

  module CanCacheClassifications
    protected

    def lookup_cached_classifications(base_filename, rows)
      filename = rows_to_filename(base_filename, rows)
      return false if !File.exists?(filename)

      f = File.open(filename, "r")
      rows.each do |row|
        row.type = f.gets.chomp.to_sym
      end
      f.close
      return true
    end

    def save_cached_classifications(base_filename, rows)
      filename = rows_to_filename(base_filename, rows)
      f = File.open(filename, "w")
      rows.each do |row|
        f.puts row.type.to_s
      end
      f.close
    end

    private

    def rows_to_filename(base_filename, rows)
      unique_str = Digest::SHA1.hexdigest(rows.map{ |row| row.key }.join)
      filename = base_filename + unique_str + ".txt"
    end
  end

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

  class AssetsCalculation < CompanyFilingCalculation
    include CanCacheClassifications
    include CanCacheSummaries
    include CanClassifyRows

    BASE_FILENAME = "summaries/ai_"

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

  end
end
