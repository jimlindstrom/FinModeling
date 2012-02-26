module FinModeling
  class BalanceSheetCalculation < CompanyFilingCalculation

    def assets
      if @assets.nil?
        friendly_goal = "assets"
        label_regexes = [ /(^total *|^)assets$/ ]
        id_regexes    = [ /^us-gaap_Assets_\d+/,
                          /^Assets_\d+/ ]
  
        calc = find_and_verify_calculation_arc(friendly_goal, label_regexes, id_regexes)
        @assets = CompanyFilingCalculation.new(@taxonomy, calc)
      end
      return @assets
    end
  
    def liabs_and_equity
       if @liabs_and_equity.nil?
        friendly_goal = "liabilities and equity"
        label_regexes = [ /(^total *|^)liabilities.*and.*equity/ ]
        id_regexes    = [ /.*/ ] # no checking...
  
        calc = find_and_verify_calculation_arc(friendly_goal, label_regexes, id_regexes)
        @liabs_and_equity = CompanyFilingCalculation.new(@taxonomy, calc)
      end
      return @liabs_and_equity
    end

  end
end
