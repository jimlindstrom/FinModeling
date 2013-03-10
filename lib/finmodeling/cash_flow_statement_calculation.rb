module FinModeling
  class CashFlowStatementCalculation < CompanyFilingCalculation
    include CanChooseSuccessivePeriods

    CASH_GOAL   = "cash change"
    CASH_LABELS = [ /^cash and cash equivalents period increase decrease/,
                    /^(|net )(change|increase|decrease|decrease *increase|increase *decrease) in cash and cash equivalents/,
                    /^net cash provided by used in (|operating activities )continuing operations/]
    CASH_IDS    = [ /^(|Locator_|loc_)(|us-gaap_)CashAndCashEquivalentsPeriodIncreaseDecrease[_a-z0-9]+/,
                    /^(|Locator_|loc_)(|us-gaap_)NetCashProvidedByUsedIn(|OperatingActivities)ContinuingOperations[_a-z0-9]+/ ]

    def cash_change_calculation
      @cash_change ||= CashChangeCalculation.new(find_calculation_arc(CASH_GOAL, CASH_LABELS, CASH_IDS))
    end
  
    def is_valid?
      re_cfs = reformulated(periods.last)
      flows_are_balanced = (re_cfs.free_cash_flow.total == (-1*re_cfs.financing_flows.total))
      none_are_zero = (re_cfs.cash_from_operations.total           != 0) &&
                      (re_cfs.cash_investments_in_operations.total != 0) &&
                      (re_cfs.payments_to_debtholders.total        != 0) &&
                      (re_cfs.payments_to_stockholders.total       != 0)
      return (flows_are_balanced && none_are_zero)
    end

    def reformulated(period)
      return ReformulatedCashFlowStatement.new(period, cash_change_calculation.summary(:period => period))
    end

    def latest_quarterly_reformulated(prev_cfs)
      if cash_change_calculation.periods.quarterly.any?
        period = cash_change_calculation.periods.quarterly.last
        lqr    = reformulated(period)
        return lqr if lqr.flows_are_plausible?
      end

      return nil if !prev_cfs

      cur_period, prev_period = choose_successive_periods(cash_change_calculation, prev_cfs.cash_change_calculation)
      if cur_period && prev_period
        return reformulated(cur_period) - prev_cfs.reformulated(prev_period)
      end
  
      return nil
    end

    def write_constructor(file, item_name)
      item_calc_name = item_name + "_calc"
      @calculation.write_constructor(file, item_calc_name)
      file.puts "#{item_name} = FinModeling::CashFlowStatementCalculation.new(#{item_calc_name})"
    end

  end
end
