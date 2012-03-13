module FinModeling
  class AssetsCalculation < CompanyFilingCalculation

    ALL_STATES  =             [ :oa, :fa ]
    ALLOWED_STATES = { nil => [ :oa, :fa ],
                       :oa => [ :oa, :fa ],
                       :fa => [ :oa, :fa ] }

    def summary(period)
      @summary = { } if @summary.nil?
      pretty_period = period.to_pretty_s
      if @summary[pretty_period].nil?
        @summary[pretty_period] = super(period, type_to_flip="credit", flip_total=false)
        if !lookup_cached_classifications(@summary[pretty_period].rows)
          classify_all_rows(@summary[pretty_period].rows, lookahead=[4, @summary[pretty_period].rows.length-1].min)
          save_cached_classifications(@summary[pretty_period].rows)
        end
      end
      return @summary[pretty_period]
    end

    private

    BASE_FILENAME = "summaries/ai_"
    def lookup_cached_classifications(rows)
      key = Digest::SHA1.hexdigest(rows.map{ |row| row[:key] }.join)
      filename = BASE_FILENAME + key + ".txt"
      return false if !File.exists?(filename)

      f = File.open(filename, "r")
      rows.each do |row|
        row[:type] = f.gets.chomp.to_sym
      end
      f.close
      return true
    end

    def save_cached_classifications(rows)
      key = Digest::SHA1.hexdigest(rows.map{ |row| row[:key] }.join)
      filename = BASE_FILENAME + key + ".txt"
      f = File.open(filename, "w")
      rows.each do |row|
        f.puts row[:type].to_s
      end
      f.close
    end

    # simple viterbi classifier, with 2-element lookahead
    def classify_all_rows(rows, lookahead)
      prev_state = nil
      rows.each_with_index do |row, idx|
        lookahead = [lookahead, rows.length-idx-lookahead].min
        row[:type] = classify_row(rows, idx, prev_state, lookahead)[:state]
        raise RuntimeError.new("couldn't classify....") if row[:type].nil?

        prev_state = row[:type]
      end
    end

    def classify_row(rows, idx, prev_state, lookahead)
      ai = FinModeling::AssetsItem.new(rows[idx][:key])
      estimates = ai.classification_estimates

      best_est           = -10000
      best_state         = nil

      best_allowed_est   = -10000
      best_allowed_state = nil

      ALL_STATES.each do |state|
        future_error = (lookahead == 0) ?  0.0 : classify_row(rows, idx+1, state, lookahead-1)[:error]
        cur_est = estimates[state] - future_error

        if cur_est > best_est
          best_est   = cur_est
          best_state = state
        end

        if !ALLOWED_STATES[prev_state].nil? and ALLOWED_STATES[prev_state].include?(state)
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
end
