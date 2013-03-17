module FinModeling
  class ComprehensiveIncomeStatementCalculation < CompanyFilingCalculation
    include CanChooseSuccessivePeriods

    CI_GOAL        = "comprehensive income"
    CI_LABELS      = [ /^comprehensive (income|loss|loss income|income loss) net of tax(| attributable to parent)$/ ]
    CI_ANTI_LABELS = [ ]
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
      puts "comprehensive income statement's comprehensive income calculation lacks net income item"    if !comprehensive_income_calculation.has_net_income_item?
      puts "comprehensive income statement's comprehensive income calculation lacks sales/revenue item" if !comprehensive_income_calculation.has_revenue_item?
      if !comprehensive_income_calculation.has_net_income_item? || !comprehensive_income_calculation.has_revenue_item?
        if comprehensive_income_calculation
          puts "summary:"
          comprehensive_income_calculation.summary(:period => periods.last).print
        end
        puts "calculation tree:\n" + self.calculation.sprint_tree(indent_count=0, simplified=true)
      end
      return (comprehensive_income_calculation.has_revenue_item? && comprehensive_income_calculation.has_net_income_item?)
    end

    def write_constructor(file, item_name)
      item_calc_name = item_name + "_calc"
      @calculation.write_constructor(file, item_calc_name)
      file.puts "#{item_name} = FinModeling::ComprehensiveIncomeStatementCalculation.new(#{item_calc_name})"
    end
  end
end
