module CanChooseSuccessivePeriods
  protected

  def choose_successive_periods(cur_calc, prev_calc)
    if         cur_calc.periods.halfyearly    .any? && prev_calc.periods.quarterly     .any?
      return [ cur_calc.periods.halfyearly    .last ,  prev_calc.periods.quarterly     .last ]
    elsif      cur_calc.periods.threequarterly.any? && prev_calc.periods.halfyearly    .any?
      return [ cur_calc.periods.threequarterly.last ,  prev_calc.periods.halfyearly    .last ]
    elsif      cur_calc.periods.yearly        .any? && prev_calc.periods.threequarterly.any?
      return [ cur_calc.periods.yearly        .last ,  prev_calc.periods.threequarterly.last ]
    end

    return [ nil, nil ]
  end
end
