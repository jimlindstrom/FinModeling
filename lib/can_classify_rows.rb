module FinModeling

  module CanClassifyRows # simple viterbi classifier, with N-element lookahead
    protected

    def classify_rows(all_states, allowed_next_states, rows, row_item_type, lookahead)
      estimate_of_item_being_in_state = rows.map { |row| row_item_type.new(row.key).classification_estimates }

      prev_state = nil
      rows.each_with_index do |row, item_index|
        cur_lookahead = [lookahead, rows.length-item_index-1].min
        row.type = classify_row(all_states, allowed_next_states, 
                                estimate_of_item_being_in_state, 
                                item_index, prev_state, cur_lookahead)[:state]
        raise RuntimeError.new("couldn't classify....") if row.type.nil?

        prev_state = row.type
      end
    end

    private

    def classify_row(all_states, allowed_next_states, estimate_of_item_being_in_state, item_index, prev_state, lookahead)
      best_overall = { :estimate => -100000000.0, :state => nil }
      best_allowed = { :estimate => -100000000.0, :state => nil }

      all_states.each do |state|
        cur = { :estimate => estimate_of_item_being_in_state[item_index][state], :state => state }
        raise RuntimeError.new("estimate is nil: #{estimate_of_item_being_in_state[item_index]} for state #{state}") if !cur[:estimate]

        if lookahead > 0
          future_error = classify_row(all_states, allowed_next_states, 
                                      estimate_of_item_being_in_state, 
                                      item_index+1, state, lookahead-1)[:error]
          cur[:estimate] -= future_error
        end

        if cur[:estimate] > best_overall[:estimate]
          best_overall = cur
        end

        is_allowed = allowed_next_states[prev_state] && allowed_next_states[prev_state].include?(state)
        if is_allowed && (cur[:estimate] > best_allowed[:estimate])
          best_allowed = cur
        end
      end

      return { :state => best_allowed[:state],
               :error => best_overall[:estimate] - 
                         best_allowed[:estimate] }
    end
  end

end
