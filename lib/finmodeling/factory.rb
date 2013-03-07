module FinModeling
  class Factory
    def self.IncomeStatementCalculation(args = {})
      entity_details = {}
      title = ""
      role = ""
      href = ""
      arcs = []
      contexts = nil

      calculation = Xbrlware::Linkbase::CalculationLinkbase::Calculation.new(entity_details, title, role, href, arcs, contexts)
      return FinModeling::IncomeStatementCalculation.new(calculation)
    end

    def self.BalanceSheetCalculation(args = {})
      entity_details = {}
      title = ""
      role = ""
      href = ""
      arcs = []
      contexts = nil

      calculation = Xbrlware::Linkbase::CalculationLinkbase::Calculation.new(entity_details, title, role, href, arcs, contexts)
      return FinModeling::BalanceSheetCalculation.new(calculation)
    end
  end
end
