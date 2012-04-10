module FinModeling
  class ShareholderEquityStatementCalculation < CompanyFilingCalculation
    #include CanChooseSuccessivePeriods

    EC_GOAL   = "change in shareholder equity"
    EC_LABELS = [ /^stockholders equity period increase decrease$/ ]
    EC_IDS    = [ /^(|Locator_|loc_)(|us-gaap_)StockholdersEquityPeriodIncreaseDecrease[_a-z0-9]+/ ]
    def equity_change_calculation
      @ec ||= EquityChangeCalculation.new(find_calculation_arc(EC_GOAL, EC_LABELS, EC_IDS))
    end

    def is_valid?
      return true
    end

#    def reformulated(period)
#      return ReformulatedIncomeStatement.new(period, 
#                                             net_income_calculation.summary(:period=>period))
#    end
#
#    def latest_quarterly_reformulated(prev_is)
#      if net_income_calculation.periods.quarterly.any?
#        period = net_income_calculation.periods.quarterly.last
#        lqr = reformulated(period)
#
#        if (lqr.operating_revenues.total.abs > 1.0) && # FIXME: make an is_valid here?
#           (lqr.cost_of_revenues  .total.abs > 1.0)    # FIXME: make an is_valid here?
#          return lqr
#        end
#      end
#
#      return nil if !prev_is
#
#      cur_period, prev_period = choose_successive_periods(net_income_calculation, prev_is.net_income_calculation)
#      if cur_period && prev_period
#        return reformulated(cur_period) - prev_is.reformulated(prev_period)
#      end
#
#      return nil
#    end
#
    def write_constructor(file, item_name)
      item_calc_name = item_name + "_calc"
      @calculation.write_constructor(file, item_calc_name)
      file.puts "#{item_name} = FinModeling::IncomeStatementCalculation.new(#{item_calc_name})"
    end

  end
end
