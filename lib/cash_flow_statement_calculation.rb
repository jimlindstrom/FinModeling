module FinModeling
  class CashFlowStatementCalculation < CompanyFilingCalculation

    def cash_change_calculation
      if @cash_change.nil?
        friendly_goal = "cash change"
        label_regexes = [ /^cash and cash equivalents period increase decrease/,
                          /^(|net )(change|increase|decrease|decrease *increase|increase *decrease) in cash and cash equivalents/,
                          /^net cash provided by used in continuing operations/]
        id_regexes    = [ /^(|Locator_|loc_)(|us-gaap_)CashAndCashEquivalentsPeriodIncreaseDecrease[_a-z0-9]+/ ]
  
        calc = find_and_verify_calculation_arc(friendly_goal, label_regexes, id_regexes)
        @cash_change = CashChangeCalculation.new(calc)
      end
      return @cash_change
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

    def latest_quarterly_reformulated(prev_cash_flow_statement)
      if cash_change_calculation.periods.quarterly.any? &&
         reformulated(cash_change_calculation.periods.quarterly.last).cash_investments_in_operations.total.abs > 1.0
        return reformulated(cash_change_calculation.periods.quarterly.last)
  
      elsif !prev_cash_flow_statement
        return nil

      elsif cash_change_calculation.periods.halfyearly.any? &&
            prev_cash_flow_statement.cash_change_calculation.periods.quarterly.any?
        cfs_period = cash_change_calculation.periods.halfyearly.last
        re_cfs     = reformulated(cfs_period)
  
        period_1q_thru_1q = prev_cash_flow_statement.cash_change_calculation.periods.quarterly.last
        prev1q  = prev_cash_flow_statement.reformulated(period_1q_thru_1q)
        re_cfs  = re_cfs - prev1q

        return re_cfs 

      elsif cash_change_calculation.periods.threequarterly.any? &&
            prev_cash_flow_statement.cash_change_calculation.periods.halfyearly.any?
        cfs_period = cash_change_calculation.periods.threequarterly.last
        re_cfs     = reformulated(cfs_period)
  
        period_1q_thru_2q = prev_cash_flow_statement.cash_change_calculation.periods.halfyearly.last
        prev2q  = prev_cash_flow_statement.reformulated(period_1q_thru_2q)
        re_cfs  = re_cfs - prev2q

        return re_cfs 

      elsif cash_change_calculation.periods.yearly.any? &&
            prev_cash_flow_statement.cash_change_calculation.periods.threequarterly.any?
        cfs_period = cash_change_calculation.periods.yearly.last
        re_cfs     = reformulated(cfs_period)
  
        period_1q_thru_3q = prev_cash_flow_statement.cash_change_calculation.periods.threequarterly.last
        prev3q  = prev_cash_flow_statement.reformulated(period_1q_thru_3q)
        re_cfs  = re_cfs - prev3q

        return re_cfs 
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
