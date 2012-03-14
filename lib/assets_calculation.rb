module FinModeling

  module CanCacheClassifications
    protected

    def lookup_cached_classifications(base_filename, rows)
      filename = rows_to_filename(base_filename, rows)
      return false if !File.exists?(filename)

      f = File.open(filename, "r")
      rows.each do |row|
        row[:type] = f.gets.chomp.to_sym
      end
      f.close
      return true
    end

    def save_cached_classifications(base_filename, rows)
      filename = rows_to_filename(base_filename, rows)
      f = File.open(filename, "w")
      rows.each do |row|
        f.puts row[:type].to_s
      end
      f.close
    end

    private

    def rows_to_filename(base_filename, rows)
      key = Digest::SHA1.hexdigest(rows.map{ |row| row[:key] }.join)
      filename = base_filename + key + ".txt"
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

  module CanClassifyRows # simple viterbi classifier, with N-element lookahead
    protected

    def classify_all_rows(all_states, next_states, rows, row_item_type, lookahead)
      prev_state = nil
      rows.each_with_index do |row, idx|
        lookahead = [lookahead, rows.length-idx-lookahead].min
        row[:type] = classify_row(all_states, next_states, rows, row_item_type, idx, prev_state, lookahead)[:state]
        raise RuntimeError.new("couldn't classify....") if row[:type].nil?

        prev_state = row[:type]
      end
    end

    def classify_row(all_states, next_states, rows, row_item_type, idx, prev_state, lookahead)
      item = row_item_type.new(rows[idx][:key])
      estimates = item.classification_estimates

      best_est           = -10000
      best_state         = nil

      best_allowed_est   = -10000
      best_allowed_state = nil

      all_states.each do |state|
        future_error = (lookahead == 0) ?  0.0 : classify_row(all_states, next_states, rows, row_item_type, idx+1, state, lookahead-1)[:error]
        cur_est = estimates[state] - future_error

        if cur_est > best_est
          best_est   = cur_est
          best_state = state
        end

        if !next_states[prev_state].nil? and next_states[prev_state].include?(state)
          if cur_est > best_allowed_est
            best_allowed_est   = cur_est
            best_allowed_state = state
          end
        end

      end

      return { :state => best_allowed_state,
               :error => best_est - best_allowed_est }
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

    def summary(period)
      summary_cache_key = period.to_pretty_s
      summary = lookup_cached_summary(summary_cache_key)
      return summary if !summary.nil?

      summary = super(period, type_to_flip="credit", flip_total=false)
      if !lookup_cached_classifications(BASE_FILENAME, summary.rows)
        lookahead = [4, summary.rows.length-1].min
        classify_all_rows(ALL_STATES, NEXT_STATES, summary.rows, FinModeling::AssetsItem, lookahead)
        save_cached_classifications(BASE_FILENAME, summary.rows)
      end

      save_cached_summary(summary_cache_key, summary)

      return summary
    end

  end
end
