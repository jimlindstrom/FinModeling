module FinModeling
  class IncomeStatementCalculation < CompanyFilingCalculation

    def operating_expenses
      if @oe.nil?
        friendly_goal = "operating expenses"
        label_regexes = [ /(^|^total )operating expense[s]*/,
                          /costs and expenses/ ]
        id_regexes    = [ /^us-gaap_CostsAndExpenses_\d+/ ]
        calc = find_and_verify_calculation_arc(friendly_goal, label_regexes, id_regexes)
        @oe = CompanyFilingCalculation.new(@taxonomy, calc)
      end
      return @oe
    end

    def operating_income
      if @oi.nil?
        friendly_goal = "operating income"
        label_regexes = [ /^operating income/,
                          /^income from operations/ ]
        id_regexes    = [ /^us-gaap_OperatingIncomeLoss_\d+/ ]
        calc = find_and_verify_calculation_arc(friendly_goal, label_regexes, id_regexes)
        @oi = CompanyFilingCalculation.new(@taxonomy, calc)
      end
      return @oi
    end

    def net_income
      if @ni.nil?
        friendly_goal = "net income"
        label_regexes = [ /^net income/,
                          /^net loss income/ ]
        id_regexes    = [ /^us-gaap_NetIncomeLoss_\d+/ ]
        calc = find_and_verify_calculation_arc(friendly_goal, label_regexes, id_regexes)
        @ni = CompanyFilingCalculation.new(@taxonomy, calc)
      end
      return @ni
    end
  
  end
end
