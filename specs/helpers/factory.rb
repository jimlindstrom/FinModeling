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
      context = self.Context(:period => args[:period])
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
      label = args[:label]

      if args[:sheet] == "google 10-k 2011-12-31"
        case args[:label]
          when nil
            item_id = ""
          when "Costs And Expenses"
            item_id = "us-gaap_CostsAndExpenses_3"
          when "Income Loss From Continuing Operations Before Income Taxes Minority Interest And Income Loss From Equity Method Investments"
            item_id = "us-gaap_IncomeLossFromContinuingOperationsBeforeIncomeTaxesMinorityInterestAndIncomeLossFromEquityMethodInvestments_3"
          when "Net Income Loss"
            item_id = "us-gaap_NetIncomeLoss_3"
          when "Operating Income Loss"
            item_id = "us-gaap_OperatingIncomeLoss_3"
          when "Income Loss From Continuing Operations Before Income Taxes Minority Interest And Income Loss From Equity Method Investments"
            item_id = "us-gaap_IncomeLossFromContinuingOperationsBeforeIncomeTaxesMinorityInterestAndIncomeLossFromEquityMethodInvestments_3"
          when "Income Tax Expense Benefit"
            item_id = "us-gaap_IncomeTaxExpenseBenefit_3"
          when "Operating Income Loss"
            item_id = "us-gaap_OperatingIncomeLoss_3"
          when "Nonoperating Income Expense"
            item_id = "us-gaap_NonoperatingIncomeExpense_3"
        end
      end

      if args[:sheet] == "google 10-k 2009-12-31"
        case args[:label]
          when nil
            item_id = ""
          when "Costs And Expenses"
            item_id = "us-gaap_CostsAndExpenses_3"
          when "Income Loss From Continuing Operations Before Income Taxes Minority Interest And Income Loss From Equity Method Investments"
            item_id = "us-gaap_IncomeLossFromContinuingOperationsBeforeIncomeTaxesMinorityInterestAndIncomeLossFromEquityMethodInvestments_3"
          when "Net Income Loss"
            item_id = "us-gaap_NetIncomeLoss_3"
          when "Operating Income Loss"
            item_id = "us-gaap_OperatingIncomeLoss_3"
          when "Income Loss From Continuing Operations Before Income Taxes Minority Interest And Income Loss From Equity Method Investments"
            item_id = "us-gaap_IncomeLossFromContinuingOperationsBeforeIncomeTaxesMinorityInterestAndIncomeLossFromEquityMethodInvestments_3"
          when "Income Tax Expense Benefit"
            item_id = "us-gaap_IncomeTaxExpenseBenefit_3"
          when "Operating Income Loss"
            item_id = "us-gaap_OperatingIncomeLoss_3"
          when "Nonoperating Income Expense"
            item_id = "us-gaap_NonoperatingIncomeExpense_3"
        end
      end

      arc = Xbrlware::Linkbase::CalculationLinkbase::Calculation::CalculationArc.new(item_id, href, role, order, 
                                                                                     weight, priority, use, label)

      if args[:sheet] == "google 10-k 2011-12-31"
        arc.items = []
        arc.children = []
        case args[:label]
          when nil
            # 
          when "Costs And Expenses"
            arc.children = []
            if !(args[:delete_sales_item] == true)
              arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                    :label => "Cost Of Revenue")
            end
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Research And Development Expense")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Selling And Marketing Expense")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "General And Administrative Expense")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Charge Related To Resolution Of Investigation")
          when "Income Loss From Continuing Operations Before Income Taxes Minority Interest And Income Loss From Equity Method Investments"
            arc.children = []
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :delete_sales_item => args[:delete_sales_item],
                                                  :label => "Operating Income Loss")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Nonoperating Income Expense")
          when "Net Income Loss"
            arc.children = []
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :delete_sales_item => args[:delete_sales_item],
                                                  :label => "Income Loss From Continuing Operations Before Income "+
                                                           "Taxes Minority Interest And Income Loss From Equity Method Investments")
            if !(args[:delete_tax_item] == true)
              arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                    :label => "Income Tax Expense Benefit")
            end
          when "Operating Income Loss"
            arc.children = []
            if !(args[:delete_sales_item] == true)
              arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                    :delete_sales_item => args[:delete_sales_item],
                                                    :label => "Sales Revenue Net")
            end
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :delete_sales_item => args[:delete_sales_item],
                                                  :label => "Costs And Expenses")
          when "Income Loss From Continuing Operations Before Income Taxes Minority Interest And Income Loss From Equity Method Investments"
            arc.children = []
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :delete_sales_item => args[:delete_sales_item],
                                                  :label => "Operating Income Loss")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Nonoperating Income Expense")
          when "Costs And Expenses"
            arc.children = []
            if !(args[:delete_sales_item] == true)
              arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                    :label => "Cost Of Revenue")
            end
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Research And Development Expense")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Selling And Marketing Expense")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "General And Administrative Expense")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Charge Related To Resolution Of Investigation" )
  
          when "Sales Revenue Net"
            arc.items = []
            arc.items.push self.Item(:name => "SalesRevenueNet",
                                     :value => "",
                                     :period => {"start_date"=>Date.parse("2009-01-01"), 
                                                 "end_date"  =>Date.parse("2009-12-31")} )
            arc.items.push self.Item(:name => "SalesRevenueNet",
                                     :value => "",
                                     :period => {"start_date"=>Date.parse("2010-01-01"), 
                                                 "end_date"  =>Date.parse("2010-12-31")} )
            arc.items.push self.Item(:name => "SalesRevenueNet",
                                     :value => "37905000000.0",
                                     :period => {"start_date"=>Date.parse("2011-01-01"), 
                                                 "end_date"  =>Date.parse("2011-12-31")} )
          when "Cost Of Revenue"
            arc.items = []
            arc.items.push self.Item(:name => "CostOfRevenue",
                                     :value => "",
                                     :period => {"start_date"=>Date.parse("2009-01-01"), 
                                                 "end_date"  =>Date.parse("2009-12-31")} )
            arc.items.push self.Item(:name => "CostOfRevenue",
                                     :value => "",
                                     :period => {"start_date"=>Date.parse("2010-01-01"), 
                                                 "end_date"  =>Date.parse("2010-12-31")} )
            arc.items.push self.Item(:name => "CostOfRevenue",
                                     :value => "13188000000.0",
                                     :period => {"start_date"=>Date.parse("2011-01-01"), 
                                                 "end_date"  =>Date.parse("2011-12-31")} )
          when "Research And Development Expense"
            arc.items = []
            arc.items.push self.Item(:name => "ResearchAndDevelopmentExpense",
                                     :value => "",
                                     :period => {"start_date"=>Date.parse("2009-01-01"), 
                                                 "end_date"  =>Date.parse("2009-12-31")} )
            arc.items.push self.Item(:name => "ResearchAndDevelopmentExpense",
                                     :value => "",
                                     :period => {"start_date"=>Date.parse("2010-01-01"), 
                                                 "end_date"  =>Date.parse("2010-12-31")} )
            arc.items.push self.Item(:name => "ResearchAndDevelopmentExpense",
                                     :value => "5162000000.0",
                                     :period => {"start_date"=>Date.parse("2011-01-01"), 
                                                 "end_date"  =>Date.parse("2011-12-31")} )
          when "Selling And Marketing Expense"
            arc.items = []
            arc.items.push self.Item(:name => "SellingAndMarketingExpense",
                                     :value => "",
                                     :period => {"start_date"=>Date.parse("2009-01-01"), 
                                                 "end_date"  =>Date.parse("2009-12-31")} )
            arc.items.push self.Item(:name => "SellingAndMarketingExpense",
                                     :value => "",
                                     :period => {"start_date"=>Date.parse("2010-01-01"), 
                                                 "end_date"  =>Date.parse("2010-12-31")} )
            arc.items.push self.Item(:name => "SellingAndMarketingExpense",
                                     :value => "4589000000.0",
                                     :period => {"start_date"=>Date.parse("2011-01-01"), 
                                                 "end_date"  =>Date.parse("2011-12-31")} )
          when "General And Administrative Expense"
            arc.items = []
            arc.items.push self.Item(:name => "GeneralAndAdministrativeExpense",
                                     :value => "",
                                     :period => {"start_date"=>Date.parse("2009-01-01"), 
                                                 "end_date"  =>Date.parse("2009-12-31")} )
            arc.items.push self.Item(:name => "GeneralAndAdministrativeExpense",
                                     :value => "",
                                     :period => {"start_date"=>Date.parse("2010-01-01"), 
                                                 "end_date"  =>Date.parse("2010-12-31")} )
            arc.items.push self.Item(:name => "GeneralAndAdministrativeExpense",
                                     :value => "2724000000.0",
                                     :period => {"start_date"=>Date.parse("2011-01-01"), 
                                                 "end_date"  =>Date.parse("2011-12-31")} )
          when "Charge Related To Resolution Of Investigation"
            arc.items = []
            arc.items.push self.Item(:name => "ChargeRelatedToResolutionOfInvestigation",
                                     :value => "",
                                     :period => {"start_date"=>Date.parse("2009-01-01"), 
                                                 "end_date"  =>Date.parse("2009-12-31")} )
            arc.items.push self.Item(:name => "ChargeRelatedToResolutionOfInvestigation",
                                     :value => "",
                                     :period => {"start_date"=>Date.parse("2010-01-01"), 
                                                 "end_date"  =>Date.parse("2010-12-31")} )
            arc.items.push self.Item(:name => "ChargeRelatedToResolutionOfInvestigation",
                                     :value => "-500000000.0",
                                     :period => {"start_date"=>Date.parse("2011-01-01"), 
                                                 "end_date"  =>Date.parse("2011-12-31")} )
          when "Nonoperating Income Expense"
            arc.items = []
            arc.items.push self.Item(:name => "NonoperatingIncomeExpense",
                                     :value => "",
                                     :period => {"start_date"=>Date.parse("2009-01-01"), 
                                                 "end_date"  =>Date.parse("2009-12-31")} )
            arc.items.push self.Item(:name => "NonoperatingIncomeExpense",
                                     :value => "",
                                     :period => {"start_date"=>Date.parse("2010-01-01"), 
                                                 "end_date"  =>Date.parse("2010-12-31")} )
            arc.items.push self.Item(:name => "NonoperatingIncomeExpense",
                                     :value => "584000000.0",
                                     :period => {"start_date"=>Date.parse("2011-01-01"), 
                                                 "end_date"  =>Date.parse("2011-12-31")} )
          when "Income Tax Expense Benefit"
            arc.items = []
            arc.items.push self.Item(:name => "IncomeTaxExpenseBenefit",
                                     :value => "",
                                     :period => {"start_date"=>Date.parse("2009-01-01"), 
                                                 "end_date"  =>Date.parse("2009-12-31")} )
            arc.items.push self.Item(:name => "IncomeTaxExpenseBenefit",
                                     :value => "",
                                     :period => {"start_date"=>Date.parse("2010-01-01"), 
                                                 "end_date"  =>Date.parse("2010-12-31")} )
            arc.items.push self.Item(:name => "IncomeTaxExpenseBenefit",
                                     :value => "2589000000.0",
                                     :period => {"start_date"=>Date.parse("2011-01-01"), 
                                                 "end_date"  =>Date.parse("2011-12-31")} )
        end
      end

      if args[:sheet] == "google 10-k 2009-12-31"
        arc.items = []
        arc.children = []
        case args[:label]
          when nil
            # 
          when "Costs And Expenses"
            arc.children = []
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Cost Of Revenue")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Research And Development Expense")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Selling And Marketing Expense")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "General And Administrative Expense")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Impairment Of Investments")
          when "Income Loss From Continuing Operations Before Income Taxes Minority Interest And Income Loss From Equity Method Investments"
            arc.children = []
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Operating Income Loss")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Other Nonoperating Income")
          when "Net Income Loss"
            arc.children = []
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Income Loss From Continuing Operations Before Income "+
                                                           "Taxes Minority Interest And Income Loss From Equity Method Investments")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Income Tax Expense Benefit")
          when "Operating Income Loss"
            arc.children = []
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Sales Revenue Net")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Costs And Expenses")
          when "Income Loss From Continuing Operations Before Income Taxes Minority Interest And Income Loss From Equity Method Investments"
            arc.children = []
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Operating Income Loss")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Other Nonoperating Income")
          when "Costs And Expenses"
            arc.children = []
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Cost Of Revenue")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Research And Development Expense")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Selling And Marketing Expense")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "General And Administrative Expense")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Impairment Of Investments")
  
          when "Sales Revenue Net"
            arc.items = []
            arc.items.push self.Item(:name => "SalesRevenueNet",
                                     :value => "",
                                     :period => {"start_date"=>Date.parse("2007-01-01"), 
                                                 "end_date"  =>Date.parse("2007-12-31")} )
            arc.items.push self.Item(:name => "SalesRevenueNet",
                                     :value => "",
                                     :period => {"start_date"=>Date.parse("2008-01-01"), 
                                                 "end_date"  =>Date.parse("2008-12-31")} )
            arc.items.push self.Item(:name => "SalesRevenueNet",
                                     :value => "23650563000.0",
                                     :decimals => "-3",
                                     :period => {"start_date"=>Date.parse("2009-01-01"), 
                                                 "end_date"  =>Date.parse("2009-12-31")} )
          when "Cost Of Revenue"
            arc.items = []
            arc.items.push self.Item(:name => "CostOfRevenue",
                                     :value => "",
                                     :period => {"start_date"=>Date.parse("2007-01-01"), 
                                                 "end_date"  =>Date.parse("2007-12-31")} )
            arc.items.push self.Item(:name => "CostOfRevenue",
                                     :value => "",
                                     :period => {"start_date"=>Date.parse("2008-01-01"), 
                                                 "end_date"  =>Date.parse("2008-12-31")} )
            arc.items.push self.Item(:name => "CostOfRevenue",
                                     :value => "8844115000.0",
                                     :decimals => "-3",
                                     :period => {"start_date"=>Date.parse("2009-01-01"), 
                                                 "end_date"  =>Date.parse("2009-12-31")} )
          when "Research And Development Expense"
            arc.items = []
            arc.items.push self.Item(:name => "ResearchAndDevelopmentExpense",
                                     :value => "",
                                     :period => {"start_date"=>Date.parse("2007-01-01"), 
                                                 "end_date"  =>Date.parse("2007-12-31")} )
            arc.items.push self.Item(:name => "ResearchAndDevelopmentExpense",
                                     :value => "",
                                     :period => {"start_date"=>Date.parse("2008-01-01"), 
                                                 "end_date"  =>Date.parse("2008-12-31")} )
            arc.items.push self.Item(:name => "ResearchAndDevelopmentExpense",
                                     :value => "2843027000.0",
                                     :decimals => "-3",
                                     :period => {"start_date"=>Date.parse("2009-01-01"), 
                                                 "end_date"  =>Date.parse("2009-12-31")} )
          when "Selling And Marketing Expense"
            arc.items = []
            arc.items.push self.Item(:name => "SellingAndMarketingExpense",
                                     :value => "",
                                     :period => {"start_date"=>Date.parse("2007-01-01"), 
                                                 "end_date"  =>Date.parse("2007-12-31")} )
            arc.items.push self.Item(:name => "SellingAndMarketingExpense",
                                     :value => "",
                                     :period => {"start_date"=>Date.parse("2008-01-01"), 
                                                 "end_date"  =>Date.parse("2008-12-31")} )
            arc.items.push self.Item(:name => "SellingAndMarketingExpense",
                                     :value => "1983941000.0",
                                     :decimals => "-3",
                                     :period => {"start_date"=>Date.parse("2009-01-01"), 
                                                 "end_date"  =>Date.parse("2009-12-31")} )
          when "General And Administrative Expense"
            arc.items = []
            arc.items.push self.Item(:name => "GeneralAndAdministrativeExpense",
                                     :value => "",
                                     :period => {"start_date"=>Date.parse("2007-01-01"), 
                                                 "end_date"  =>Date.parse("2007-12-31")} )
            arc.items.push self.Item(:name => "GeneralAndAdministrativeExpense",
                                     :value => "",
                                     :period => {"start_date"=>Date.parse("2008-01-01"), 
                                                 "end_date"  =>Date.parse("2008-12-31")} )
            arc.items.push self.Item(:name => "GeneralAndAdministrativeExpense",
                                     :value => "1667294000.0",
                                     :decimals => "-3",
                                     :period => {"start_date"=>Date.parse("2009-01-01"), 
                                                 "end_date"  =>Date.parse("2009-12-31")} )
          when "Impairment Of Investments"
            arc.items = []
            arc.items.push self.Item(:name => "ImpairmentOfInvestments",
                                     :value => "",
                                     :period => {"start_date"=>Date.parse("2007-01-01"), 
                                                 "end_date"  =>Date.parse("2007-12-31")} )
            arc.items.push self.Item(:name => "ImpairmentOfInvestments",
                                     :value => "",
                                     :period => {"start_date"=>Date.parse("2008-01-01"), 
                                                 "end_date"  =>Date.parse("2008-12-31")} )
            arc.items.push self.Item(:name => "ImpairmentOfInvestments",
                                     :value => "0.0",
                                     :decimals => "-3",
                                     :period => {"start_date"=>Date.parse("2009-01-01"), 
                                                 "end_date"  =>Date.parse("2009-12-31")} )
          when "Other Nonoperating Income"
            arc.items = []
            arc.items.push self.Item(:name => "OtherNonoperatingIncome",
                                     :value => "",
                                     :period => {"start_date"=>Date.parse("2007-01-01"), 
                                                 "end_date"  =>Date.parse("2007-12-31")} )
            arc.items.push self.Item(:name => "OtherNonoperatingIncome",
                                     :value => "",
                                     :period => {"start_date"=>Date.parse("2008-01-01"), 
                                                 "end_date"  =>Date.parse("2008-12-31")} )
            arc.items.push self.Item(:name => "OtherNonoperatingIncome",
                                     :value => "69003000.0",
                                     :decimals => "-3",
                                     :period => {"start_date"=>Date.parse("2009-01-01"), 
                                                 "end_date"  =>Date.parse("2009-12-31")} )
          when "Income Tax Expense Benefit"
            arc.items = []
            arc.items.push self.Item(:name => "IncomeTaxExpenseBenefit",
                                     :value => "",
                                     :period => {"start_date"=>Date.parse("2007-01-01"), 
                                                 "end_date"  =>Date.parse("2007-12-31")} )
            arc.items.push self.Item(:name => "IncomeTaxExpenseBenefit",
                                     :value => "",
                                     :period => {"start_date"=>Date.parse("2008-01-01"), 
                                                 "end_date"  =>Date.parse("2008-12-31")} )
            arc.items.push self.Item(:name => "IncomeTaxExpenseBenefit",
                                     :value => "1860741000.0",
                                     :decimals => "-3",
                                     :period => {"start_date"=>Date.parse("2009-01-01"), 
                                                 "end_date"  =>Date.parse("2009-12-31")} )
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
    
          arcs.push self.CalculationArc(:sheet => args[:sheet],
                                        :delete_sales_item => args[:delete_sales_item],
                                        :label => "Costs And Expenses")
          arcs.push self.CalculationArc(:sheet => args[:sheet],
                                        :delete_sales_item => args[:delete_sales_item],
                                        :label => "Income Loss From Continuing Operations Before Income Taxes Minority Interest " +
                                                  "And Income Loss From Equity Method Investments")
          arcs.push self.CalculationArc(:sheet => args[:sheet],
                                        :delete_sales_item => args[:delete_sales_item],
                                        :delete_tax_item => args[:delete_tax_item],
                                        :label => "Net Income Loss")
          arcs.push self.CalculationArc(:sheet => args[:sheet],
                                        :delete_sales_item => args[:delete_sales_item],
                                        :label => "Operating Income Loss")
        when "google 10-k 2009-12-31"
          entity_details = {"name"=>"Google Inc.", 
                            "ci_key"=>"0001288776", 
                            "doc_type"=>"10-K", 
                            "doc_end_date"=>"2009-12-31", 
                            "fiscal_end_date"=>"--12-31", 
                            "common_shares_outstanding"=>"-1",  # FIXME
                            "symbol"=>"GOOG"}
          title = "Statement Of Income"
          role = "http://www.google.com/taxonomy/role/StatementOfIncome"
          href = "Role_StatementOfIncome"
    
          arcs.push self.CalculationArc(:sheet => args[:sheet],
                                        :label => "Costs And Expenses")
          arcs.push self.CalculationArc(:sheet => args[:sheet],
                                        :label => "Income Loss From Continuing Operations Before Income Taxes Minority Interest " +
                                                  "And Income Loss From Equity Method Investments")
          arcs.push self.CalculationArc(:sheet => args[:sheet],
                                        :label => "Net Income Loss")
          arcs.push self.CalculationArc(:sheet => args[:sheet],
                                        :label => "Operating Income Loss")
      end

      calculation = Xbrlware::Linkbase::CalculationLinkbase::Calculation.new(entity_details, title, role, href, arcs, contexts)
      return FinModeling::IncomeStatementCalculation.new(taxonomy=nil, calculation)
    end
  end
end
