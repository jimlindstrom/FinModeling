module FinModeling
  class ComprehensiveIncomeStatementCalculation < CompanyFilingCalculation
    include CanChooseSuccessivePeriods

    CI_GOAL        = "comprehensive income"
    CI_LABELS      = [ /^comprehensive (income|loss|loss income|income loss)(| net of tax)(| attributable to .*)$/ ]
    CI_ANTI_LABELS = [ /noncontrolling interest/, 
                       /minority interest/ ]
    CI_IDS         = [ /^(|Locator_|loc_)(|us-gaap_)ComprehensiveIncomeNetOfTax[_0-9a-z]+/ ] 
    def comprehensive_income_calculation
      begin
        @ci ||= ComprehensiveIncomeCalculation.new(find_calculation_arc(CI_GOAL, CI_LABELS, CI_ANTI_LABELS, CI_IDS))
      rescue FinModeling::InvalidFilingError => e
        pre_msg = "calculation tree:\n" + self.calculation.sprint_tree
        raise e, pre_msg+e.message, e.backtrace
      end
    end

    def is_valid?
      if !comprehensive_income_calculation.has_net_income_item? && !comprehensive_income_calculation.has_revenue_item?
        puts "comprehensive income statement's comprehensive income calculation lacks net income item"
        puts "comprehensive income statement's comprehensive income calculation lacks sales/revenue item"
        if comprehensive_income_calculation
          puts "summary:"
          comprehensive_income_calculation.summary(:period => periods.last).print
        end
        puts "calculation tree:\n" + self.calculation.sprint_tree(indent_count=0, simplified=true)
      end
      return (comprehensive_income_calculation.has_revenue_item? || comprehensive_income_calculation.has_net_income_item?)
    end

    def reformulated(period, dummy_comprehensive_income_calculation) # 2nd param is just to keep signature consistent w/ IncomeStatement::reformulated
      # The way ReformulatedIncomeStatement.new() is implemented, it'll just ignore rows with types it 
      # doesn't know about (like OCI). So this should extract just the NI-related rows.
      return ReformulatedIncomeStatement.new(period,
                                             comprehensive_income_calculation.summary(:period=>period), # NI
                                             comprehensive_income_calculation.summary(:period=>period)) # CI
    end

    def latest_quarterly_reformulated(dummy_cur_ci_calc, prev_stmt, prev_ci_calc)
      if comprehensive_income_calculation.periods.quarterly.any?
        period = comprehensive_income_calculation.periods.quarterly.last
        lqr = reformulated(period, comprehensive_income_calculation)

        if (lqr.operating_revenues.total.abs > 1.0) && # FIXME: make an is_valid here?
           (lqr.cost_of_revenues  .total.abs > 1.0)    # FIXME: make an is_valid here?
          return lqr
        end
      end

      return nil if !prev_stmt

      prev_calc = prev_stmt.respond_to?(:net_income_calculation) ? prev_stmt.net_income_calculation : prev_stmt.comprehensive_income_calculation

      cur_period, prev_period = choose_successive_periods(comprehensive_income_calculation, prev_calc)
      if cur_period && prev_period
        new_re_is = reformulated(cur_period, comprehensive_income_calculation) - prev_stmt.reformulated(prev_period, prev_ci_calc)
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
      file.puts "#{item_name} = FinModeling::ComprehensiveIncomeStatementCalculation.new(#{item_calc_name})"
    end
  end
end
