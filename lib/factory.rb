module FinModeling
  class Factory
    def self.Entity(args = {})
      entity = Xbrlware::Entity.new(args[:identifier], args[:segment])

      return entity
    end

    def self.Context(args = {})
      id = args[:id] || ""
      entity = args[:entity] || self.Entity()
      period = args[:period]
      scenario = args[:scenario]
      context = Xbrlware::Context.new(id, entity, period, scenario)

      return context
    end

    def self.Item(args = {})
      instance = nil
      name = args[:name] || ""
      context = args[:context] || self.Context(:period => args[:period])
      value = args[:value] || ""
      unit = args[:unit]
      precision = args[:precision]
      decimals = args[:decimals] || "-6"
      footnotes = nil
      
      item = Xbrlware::Item.new(instance, name, context, value, unit, precision, decimals, footnotes)

      return item
    end

    def self.CalculationArc(args = {})
      item_id = args[:item_id] || ""
      href = ""
      role = nil
      order = nil
      weight = nil
      priority = nil
      use = nil
      label = args[:label] || ""

      arc = Xbrlware::Linkbase::CalculationLinkbase::Calculation::CalculationArc.new(item_id, href, role, order, 
                                                                                     weight, priority, use, label)

      return arc
    end

    def self.Calculation(args = {})
      entity_details=nil
      title=args[:title] || ""
      role=args[:role]
      href=nil
      arcs=args[:arcs] || []
      contexts=nil

      return Xbrlware::Linkbase::CalculationLinkbase::Calculation.new(entity_details, title, role, href, arcs, contexts)
    end

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
