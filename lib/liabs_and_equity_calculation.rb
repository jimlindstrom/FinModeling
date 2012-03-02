module FinModeling
  class LiabsAndEquityCalculation < CompanyFilingCalculation

    ALL_STATES  =              [ :ol, :fl, :cse ]
    ALLOWED_STATES = { nil  => [ :ol, :fl, :cse ],
                       :ol  => [ :ol, :fl, :cse ],
                       :fl  => [ :ol, :fl, :cse ],
                       :cse => [      :fl, :cse ] }

    def summary(period)
      s = super(period, type_to_flip="debit", flip_total=true)
    
      classify_all_rows(s.rows, lookahead=[4, s.rows.length-1].min)

      return s
    end

    private

    # simple viterbi classifier, with 2-element lookahead
    def classify_all_rows(rows, lookahead)
      prev_state = nil
      rows[0..-2].each_with_index do |row, idx|
        lookahead = [lookahead, rows.length-idx-lookahead].min
        row[:type] = classify_row(rows, idx, prev_state, lookahead)[:state]
        raise RuntimeError.new("couldn't classify....") if row[:type].nil?

        prev_state = row[:type]
      end
    end

    def classify_row(rows, idx, prev_state, lookahead)
      ai = FinModeling::LiabsAndEquityItem.new(rows[idx][:key])
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
