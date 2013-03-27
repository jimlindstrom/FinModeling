module FinModeling
  class ShareholderEquityStatementCalculation < CompanyFilingCalculation
    #include CanChooseSuccessivePeriods

    EC_GOAL        = "change in shareholder equity"
    EC_LABELS      = [ /^stockholders equity period increase decrease$/ ]
    EC_ANTI_LABELS = [ ]
    EC_IDS         = [ /^(|Locator_|loc_)(|us-gaap_)StockholdersEquityPeriodIncreaseDecrease[_a-z0-9]+/ ]
    def equity_change_calculation
      begin
        @ec ||= EquityChangeCalculation.new(find_calculation_arc(EC_GOAL, EC_LABELS, EC_ANTI_LABELS, EC_IDS))
      rescue FinModeling::InvalidFilingError => e
        pre_msg = "calculation tree:\n" + self.calculation.sprint_tree
        raise e, pre_msg+e.message, e.backtrace
      end
    end

    def is_valid?
      return true
    end

    def reformulated(period)
      return ReformulatedShareholderEquityStatement.new(period, 
                                                        equity_change_calculation.summary(:period=>period))
    end

    def write_constructor(file, item_name)
      item_calc_name = item_name + "_calc"
      @calculation.write_constructor(file, item_calc_name)
      file.puts "#{item_name} = FinModeling::ShareholderEquityStatementCalculation.new(#{item_calc_name})"
    end

  end
end
