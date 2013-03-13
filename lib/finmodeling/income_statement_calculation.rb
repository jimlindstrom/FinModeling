module FinModeling
  class IncomeStatementCalculation < CompanyFilingCalculation
    include CanChooseSuccessivePeriods

    NI_GOAL   = "net income"
    NI_LABELS = [ /^(|consolidated )net (|income loss|loss income|income|loss|)(| net of tax)(| attributable to parent)/,
                  /^profit loss$/,
                  /^allocation.*of.*undistributed.*earnings/ ]
    NI_IDS    = [ /^(|Locator_|loc_)(|us-gaap_)NetIncomeLoss[_0-9a-z]+/,
                  /^(|Locator_|loc_)(|us-gaap_)NetIncomeLossAvailableToCommonStockholdersBasic[_0-9a-z]+/,
                  /^(|Locator_|loc_)(|us-gaap_)ProfitLoss[_0-9a-z]+/ ]
    def net_income_calculation
      begin
        @ni ||= NetIncomeCalculation.new(find_calculation_arc(NI_GOAL, NI_LABELS, NI_IDS))
      rescue FinModeling::InvalidFilingError => e
        pre_msg = "calculation tree:\n" + self.calculation.sprint_tree
        raise e, pre_msg+e.message, e.backtrace
      end
    end

    def is_valid?
      puts "income statement's net income calculation lacks tax item"           if !net_income_calculation.has_tax_item?
      puts "income statement's net income calculation lacks sales/revenue item" if !net_income_calculation.has_revenue_item?
      if !net_income_calculation.has_tax_item? || !net_income_calculation.has_revenue_item?
        if net_income_calculation
          puts "summary:"
          net_income_calculation.summary(:period => periods.last).print
        end
        puts "calculation tree:\n" + self.calculation.sprint_tree(indent_count=0, simplified=true)
      end
      return (net_income_calculation.has_revenue_item? && net_income_calculation.has_tax_item?)
    end

    def reformulated(period)
      return ReformulatedIncomeStatement.new(period, 
                                             net_income_calculation.summary(:period=>period))
    end

    def latest_quarterly_reformulated(prev_is)
      if net_income_calculation.periods.quarterly.any?
        period = net_income_calculation.periods.quarterly.last
        lqr = reformulated(period)

        if (lqr.operating_revenues.total.abs > 1.0) && # FIXME: make an is_valid here?
           (lqr.cost_of_revenues  .total.abs > 1.0)    # FIXME: make an is_valid here?
          return lqr
        end
      end

      return nil if !prev_is

      cur_period, prev_period = choose_successive_periods(net_income_calculation, prev_is.net_income_calculation)
      if cur_period && prev_period
        new_re_is = reformulated(cur_period) - prev_is.reformulated(prev_period)
        # the above subtraction doesn't know what period you want. So let's patch the result to have
        # a quarterly period with the right end-points
        new_re_is.period = Xbrlware::Context::Period.new({"start_date"=>prev_period.value["end_date"], 
                                                          "end_date"  =>cur_period.value["end_date"]})
        return new_re_is
      end

      return nil
    end

    def write_constructor(file, item_name)
      item_calc_name = item_name + "_calc"
      @calculation.write_constructor(file, item_calc_name)
      file.puts "#{item_name} = FinModeling::IncomeStatementCalculation.new(#{item_calc_name})"
    end

  end
end
