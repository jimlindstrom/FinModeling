module FinModeling
  class CashFlowStatementCalculation < CompanyFilingCalculation

    def cash_change_calculation
      if @cash_change.nil?
        friendly_goal = "cash change"
        label_regexes = [ /^cash and cash equivalents period increase decrease/,
                          /^net (change|increase|decrease|increase decrease) in cash and cash equivalents/,
                          /^net cash provided by used in continuing operations/]
        id_regexes    = [ /^(|loc_|us-gaap_)CashAndCashEquivalentsPeriodIncreaseDecrease(|_)\d+/ ]
  
        calc = find_and_verify_calculation_arc(friendly_goal, label_regexes, id_regexes)
        @cash_change = CashChangeCalculation.new(calc)
      end
      return @cash_change
    end
  
    def is_valid?
      period = periods.last
      flows_are_balanced = (   reformulated(period).free_cash_flow.total ==
                            -1*reformulated(period).financing_flows.total)
      return flows_are_balanced
    end

    def reformulated(period)
      return ReformulatedCashFlowStatement.new(period, cash_change_calculation.summary(:period => period))
    end

    def write_constructor(file, item_name)
      item_calc_name = item_name + "_calc"
      @calculation.write_constructor(file, item_calc_name)
      file.puts "#{item_name} = FinModeling::CashFlowStatementCalculation.new(#{item_calc_name})"
    end

  end
end
