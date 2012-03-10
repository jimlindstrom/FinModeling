module FinModeling
  class Factory
    def self.Period(value)
      period = Xbrlware::Context::Period.new(value)

      return period
    end

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
      context = args[:context] || self.Context(:args => (args[:period] || nil) )
      value = args[:value] || ""
      unit = args[:unit]
      precision = args[:precision]
      decimals = args[:decimals] || "-6"
      footnotes = nil
      
      item = Xbrlware::Item.new(instance, name, context, value, unit, precision, decimals, footnotes)

      return item
    end

    def self.CalculationArc(args = {})
      item_id = ""
      href = ""
      role = nil
      order = nil
      weight = nil
      priority = nil
      use = nil
      label = nil

      if !args[:label].nil?
        case args[:label]
          when "Costs And Expenses"
            item_id = "us-gaap_CostsAndExpenses_3"
            label = args[:label]
          when "Income Loss From Continuing Operations Before Income Taxes Minority Interest And Income Loss From Equity Method Investments"
            item_id = "us-gaap_IncomeLossFromContinuingOperationsBeforeIncomeTaxesMinorityInterestAndIncomeLossFromEquityMethodInvestments_3"
            label = args[:label]
          when "Net Income Loss"
            item_id = "us-gaap_NetIncomeLoss_3"
            label = args[:label]
          when "Operating Income Loss"
            item_id = "us-gaap_OperatingIncomeLoss_3"
            label = args[:label]
          when "Income Loss From Continuing Operations Before Income Taxes Minority Interest And Income Loss From Equity Method Investments"
            item_id = "us-gaap_IncomeLossFromContinuingOperationsBeforeIncomeTaxesMinorityInterestAndIncomeLossFromEquityMethodInvestments_3"
            label = args[:label]
          when "Income Tax Expense Benefit"
            item_id = "us-gaap_IncomeTaxExpenseBenefit_3"
            label = args[:label]
          when "Operating Income Loss"
            item_id = "us-gaap_OperatingIncomeLoss_3"
            label = args[:label]
          when "Nonoperating Income Expense"
            item_id = "us-gaap_NonoperatingIncomeExpense_3"
            label = args[:label]
        end
      end

      arc = Xbrlware::Linkbase::CalculationLinkbase::Calculation::CalculationArc.new(item_id, href, role, order, 
                                                                                     weight, priority, use, label)

      if !args[:label].nil?
        case args[:label]
          when "Costs And Expenses"
            arc.children.add self.CalculationArc(:label => "Cost Of Revenue")
            arc.children.add self.CalculationArc(:label => "Research And Development Expense")
            arc.children.add self.CalculationArc(:label => "Selling And Marketing Expense")
            arc.children.add self.CalculationArc(:label => "General And Administrative Expense")
            arc.children.add self.CalculationArc(:label => "Charge Related To Resolution Of Investigation")
          when "Income Loss From Continuing Operations Before Income Taxes Minority Interest And Income Loss From Equity Method Investments"
            arc.children.add self.CalculationArc(:label => "Operating Income Loss")
            arc.children.add self.CalculationArc(:label => "Nonoperating Income Expense")
          when "Net Income Loss"
            arc.children.add self.CalculationArc(:label => "Income Loss From Continuing Operations Before Income "+
                                                           "Taxes Minority Interest And Income Loss From Equity Method Investments")
            arc.children.add self.CalculationArc(:label => "Income Tax Expense Benefit")
          when "Operating Income Loss"
            arc.children.add self.CalculationArc(:label => "Sales Revenue Net")
            arc.children.add self.CalculationArc(:label => "Costs And Expenses")
          when "Income Loss From Continuing Operations Before Income Taxes Minority Interest And Income Loss From Equity Method Investments"
            arc.children.add self.CalculationArc(:label => "Operating Income Loss")
            arc.children.add self.CalculationArc(:label => "Nonoperating Income Expense")
          when "Costs And Expenses"
            arc.children.add self.CalculationArc(:label => "Cost Of Revenue")
            arc.children.add self.CalculationArc(:label => "Research And Development Expense")
            arc.children.add self.CalculationArc(:label => "Selling And Marketing Expense")
            arc.children.add self.CalculationArc(:label => "General And Administrative Expense")
            arc.children.add self.CalculationArc(:label => "Charge Related To Resolution Of Investigation" )

          when "Sales Revenue Net"
            arc.items = []
            arc.items.push self.Item(:name => "SalesRevenueNet",
                                     :period => self.Period( {"start_date"=>Date.parse("2009-01-01"), 
                                                              "end_date"  =>Date.parse("2009-12-31")} ) )
            arc.items.push self.Item(:name => "SalesRevenueNet",
                                     :period => self.Period( {"start_date"=>Date.parse("2010-01-01"), 
                                                              "end_date"  =>Date.parse("2010-12-31")} ) )
            arc.items.push self.Item(:name => "SalesRevenueNet",
                                     :period => self.Period( {"start_date"=>Date.parse("2011-01-01"), 
                                                              "end_date"  =>Date.parse("2011-12-31")} ) )
          when "Cost Of Revenue"
            arc.items = []
            arc.items.push self.Item(:name => "CostOfRevenue",
                                     :period => self.Period( {"start_date"=>Date.parse("2009-01-01"), 
                                                              "end_date"  =>Date.parse("2009-12-31")} ) )
            arc.items.push self.Item(:name => "CostOfRevenue",
                                     :period => self.Period( {"start_date"=>Date.parse("2010-01-01"), 
                                                              "end_date"  =>Date.parse("2010-12-31")} ) )
            arc.items.push self.Item(:name => "CostOfRevenue",
                                     :period => self.Period( {"start_date"=>Date.parse("2011-01-01"), 
                                                              "end_date"  =>Date.parse("2011-12-31")} ) )
          when "Research And Development Expense"
            arc.items = []
            arc.items.push self.Item(:name => "ResearchAndDevelopmentExpense",
                                     :period => self.Period( {"start_date"=>Date.parse("2009-01-01"), 
                                                              "end_date"  =>Date.parse("2009-12-31")} ) )
            arc.items.push self.Item(:name => "ResearchAndDevelopmentExpense",
                                     :period => self.Period( {"start_date"=>Date.parse("2010-01-01"), 
                                                              "end_date"  =>Date.parse("2010-12-31")} ) )
            arc.items.push self.Item(:name => "ResearchAndDevelopmentExpense",
                                     :period => self.Period( {"start_date"=>Date.parse("2011-01-01"), 
                                                              "end_date"  =>Date.parse("2011-12-31")} ) )
          when "Selling And Marketing Expense"
            arc.items = []
            arc.items.push self.Item(:name => "SellingAndMarketingExpense",
                                     :period => self.Period( {"start_date"=>Date.parse("2009-01-01"), 
                                                              "end_date"  =>Date.parse("2009-12-31")} ) )
            arc.items.push self.Item(:name => "SellingAndMarketingExpense",
                                     :period => self.Period( {"start_date"=>Date.parse("2010-01-01"), 
                                                              "end_date"  =>Date.parse("2010-12-31")} ) )
            arc.items.push self.Item(:name => "SellingAndMarketingExpense",
                                     :period => self.Period( {"start_date"=>Date.parse("2011-01-01"), 
                                                              "end_date"  =>Date.parse("2011-12-31")} ) )
          when "General And Administrative Expense"
            arc.items = []
            arc.items.push self.Item(:name => "GeneralAndAdministrativeExpense",
                                     :period => self.Period( {"start_date"=>Date.parse("2009-01-01"), 
                                                              "end_date"  =>Date.parse("2009-12-31")} ) )
            arc.items.push self.Item(:name => "GeneralAndAdministrativeExpense",
                                     :period => self.Period( {"start_date"=>Date.parse("2010-01-01"), 
                                                              "end_date"  =>Date.parse("2010-12-31")} ) )
            arc.items.push self.Item(:name => "GeneralAndAdministrativeExpense",
                                     :period => self.Period( {"start_date"=>Date.parse("2011-01-01"), 
                                                              "end_date"  =>Date.parse("2011-12-31")} ) )
          when "Charge Related To Resolution Of Investigation"
            arc.items = []
            arc.items.push self.Item(:name => "ChargeRelatedToResolutionOfInvestigation",
                                     :period => self.Period( {"start_date"=>Date.parse("2009-01-01"), 
                                                              "end_date"  =>Date.parse("2009-12-31")} ) )
            arc.items.push self.Item(:name => "ChargeRelatedToResolutionOfInvestigation",
                                     :period => self.Period( {"start_date"=>Date.parse("2010-01-01"), 
                                                              "end_date"  =>Date.parse("2010-12-31")} ) )
            arc.items.push self.Item(:name => "ChargeRelatedToResolutionOfInvestigation",
                                     :period => self.Period( {"start_date"=>Date.parse("2011-01-01"), 
                                                              "end_date"  =>Date.parse("2011-12-31")} ) )
          when "Nonoperating Income Expense"
            arc.items = []
            arc.items.push self.Item(:name => "NonoperatingIncomeExpense",
                                     :period => self.Period( {"start_date"=>Date.parse("2009-01-01"), 
                                                              "end_date"  =>Date.parse("2009-12-31")} ) )
            arc.items.push self.Item(:name => "NonoperatingIncomeExpense",
                                     :period => self.Period( {"start_date"=>Date.parse("2010-01-01"), 
                                                              "end_date"  =>Date.parse("2010-12-31")} ) )
            arc.items.push self.Item(:name => "NonoperatingIncomeExpense",
                                     :period => self.Period( {"start_date"=>Date.parse("2011-01-01"), 
                                                              "end_date"  =>Date.parse("2011-12-31")} ) )
          when "Income Tax Expense Benefit"
            arc.items = []
            arc.items.push self.Item(:name => "IncomeTaxExpenseBenefit",
                                     :period => self.Period( {"start_date"=>Date.parse("2009-01-01"), 
                                                              "end_date"  =>Date.parse("2009-12-31")} ) )
            arc.items.push self.Item(:name => "IncomeTaxExpenseBenefit",
                                     :period => self.Period( {"start_date"=>Date.parse("2010-01-01"), 
                                                              "end_date"  =>Date.parse("2010-12-31")} ) )
            arc.items.push self.Item(:name => "IncomeTaxExpenseBenefit",
                                     :period => self.Period( {"start_date"=>Date.parse("2011-01-01"), 
                                                              "end_date"  =>Date.parse("2011-12-31")} ) )
        end
      end


      return arc
    end

    def self.IncomeStatementCalculation(args = {})
      entity_details = {}
      title = ""
      role = ""
      href = ""
      arcs = []
      contexts = nil

      case args[:sheet]
        when "google 10-k 2011-12-31"
          entity_details = {"name"=>"Google Inc.", 
                            "ci_key"=>"0001288776", 
                            "doc_type"=>"10-K", 
                            "doc_end_date"=>"2011-12-31", 
                            "fiscal_end_date"=>"--12-31", 
                            "common_shares_outstanding"=>"67175694", 
                            "symbol"=>"GOOG"}
          title = "Statement Of Income"
          role = "http://www.google.com/taxonomy/role/StatementOfIncome"
          href = "Role_StatementOfIncome"
    
          arcs.push self.CalculationArc(:label => "Costs And Expenses")
          arcs.push self.CalculationArc(:label => "Income Loss From Continuing Operations Before Income Taxes Minority Interest " +
                                                  "And Income Loss From Equity Method Investments")
          arcs.push self.CalculationArc(:label => "Net Income Loss")
          arcs.push self.CalculationArc(:label => "Operating Income Loss")
      end

      calculation = Xbrlware::Linkbase::CalculationLinkbase::Calculation.new(entity_details, title, role, href, arcs, contexts)
      return FinModeling::IncomeStatementCalculation.new(taxonomy=nil, calculation)
    end
  end
end
