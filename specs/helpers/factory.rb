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

      if args[:sheet] == "google 10-k 2011-12-31 income statement"
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

      if args[:sheet] == "google 10-k 2009-12-31 income statement"
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

      if args[:sheet] == "google 10-k 2011-12-31 balance sheet"
        arc.items = []
        arc.children = []
        case args[:label]
          when "Assets"
            arc.children = []
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Assets Current")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Prepaid Revenue Share Expenses And Other Assets Noncurrent")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Deferred Tax Assets Net Noncurrent")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Other Long Term Investments")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Property Plant And Equipment Net")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Intangible Assets Net Excluding Goodwill")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Goodwill")
          when "Assets Current"
            arc.children = []
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Cash Cash Equivalents And Short Term Investments")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Accounts Receivable Net Current")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Receivable Under Reverse Repurchase Agreements")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Deferred Tax Assets Net Current")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Prepaid Revenue Share Expenses And Other Assets Current")
          when "Cash Cash Equivalents And Short Term Investments"
            arc.children = []
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Cash And Cash Equivalents At Carrying Value")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Available For Sale Securities Current")
          ###########################################################################################
          when "Liabilities And Stockholders Equity"
            arc.children = []
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Liabilities Current")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Long Term Debt Noncurrent")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Deferred Revenue Noncurrent")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Liability For Uncertain Tax Positions Noncurrent")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Deferred Tax Liabilities Noncurrent")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Other Liabilities Noncurrent")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Stockholders Equity")
          when "Liabilities Current"
            arc.children = []
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Accounts Payable Current")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Short Term Borrowings")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Employee Related Liabilities Current")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Accrued Liabilities Current")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Accrued Revenue Share")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Securities Lending Payable")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Deferred Revenue Current")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Accrued Income Taxes Current")
          when "Stockholders Equity"
            arc.children = []
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Convertible Preferred Stock Nonredeemable Or Redeemable Issuer Option Value")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Common Stock Including Additional Paid In Capital")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Accumulated Other Comprehensive Income Loss Net Of Tax")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Retained Earnings Accumulated Deficit")
          ###########################################################################################
          when "Cash And Cash Equivalents At Carrying Value"
            arc.items = []
            ["2008-12-31", "2009-12-31", "2010-12-31", "2011-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "9983000000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Available For Sale Securities Current"
            arc.items = []
            ["2008-12-31", "2009-12-31", "2010-12-31", "2011-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "34643000000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Accounts Receivable Net Current"
            arc.items = []
            ["2008-12-31", "2009-12-31", "2010-12-31", "2011-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "5427000000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Receivable Under Reverse Repurchase Agreements"
            arc.items = []
            ["2008-12-31", "2009-12-31", "2010-12-31", "2011-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "745000000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Deferred Tax Assets Net Current"
            arc.items = []
            ["2008-12-31", "2009-12-31", "2010-12-31", "2011-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "215000000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Prepaid Revenue Share Expenses And Other Assets Current"
            arc.items = []
            ["2008-12-31", "2009-12-31", "2010-12-31", "2011-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "1745000000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Prepaid Revenue Share Expenses And Other Assets Noncurrent"
            arc.items = []
            ["2008-12-31", "2009-12-31", "2010-12-31", "2011-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "499000000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Deferred Tax Assets Net Noncurrent"
            arc.items = []
            ["2008-12-31", "2009-12-31", "2010-12-31", "2011-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Other Long Term Investments"
            arc.items = []
            ["2008-12-31", "2009-12-31", "2010-12-31", "2011-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "-790000000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Property Plant And Equipment Net"
            arc.items = []
            ["2008-12-31", "2009-12-31", "2010-12-31", "2011-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "9603000000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Intangible Assets Net Excluding Goodwill"
            arc.items = []
            ["2008-12-31", "2009-12-31", "2010-12-31", "2011-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "1578000000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Goodwill"
            arc.items = []
            ["2008-12-31", "2009-12-31", "2010-12-31", "2011-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "7346000000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          ###########################################################################################
          when "Accounts Payable Current"
            arc.items = []
            ["2008-12-31", "2009-12-31", "2010-12-31", "2011-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "588000000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Short Term Borrowings"
            arc.items = []
            ["2008-12-31", "2009-12-31", "2010-12-31", "2011-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "-1218000000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Employee Related Liabilities Current"
            arc.items = []
            ["2008-12-31", "2009-12-31", "2010-12-31", "2011-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "1818000000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Accrued Liabilities Current"
            arc.items = []
            ["2008-12-31", "2009-12-31", "2010-12-31", "2011-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "1370000000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Accrued Revenue Share"
            arc.items = []
            ["2008-12-31", "2009-12-31", "2010-12-31", "2011-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "1168000000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Securities Lending Payable"
            arc.items = []
            ["2008-12-31", "2009-12-31", "2010-12-31", "2011-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "2007000000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Deferred Revenue Current"
            arc.items = []
            ["2008-12-31", "2009-12-31", "2010-12-31", "2011-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "547000000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Accrued Income Taxes Current"
            arc.items = []
            ["2008-12-31", "2009-12-31", "2010-12-31", "2011-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "197000000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Long Term Debt Noncurrent"
            arc.items = []
            ["2008-12-31", "2009-12-31", "2010-12-31", "2011-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "2986000000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Deferred Revenue Noncurrent"
            arc.items = []
            ["2008-12-31", "2009-12-31", "2010-12-31", "2011-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "44000000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Liability For Uncertain Tax Positions Noncurrent"
            arc.items = []
            ["2008-12-31", "2009-12-31", "2010-12-31", "2011-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "1693000000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Deferred Tax Liabilities Noncurrent"
            arc.items = []
            ["2008-12-31", "2009-12-31", "2010-12-31", "2011-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "287000000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Other Liabilities Noncurrent"
            arc.items = []
            ["2008-12-31", "2009-12-31", "2010-12-31", "2011-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "506000000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Convertible Preferred Stock Nonredeemable Or Redeemable Issuer Option Value"
            arc.items = []
            ["2008-12-31", "2009-12-31", "2010-12-31", "2011-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "0.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Common Stock Including Additional Paid In Capital"
            arc.items = []
            ["2008-12-31", "2009-12-31", "2010-12-31", "2011-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "20264000000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Accumulated Other Comprehensive Income Loss Net Of Tax"
            arc.items = []
            ["2008-12-31", "2009-12-31", "2010-12-31", "2011-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "276000000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Retained Earnings Accumulated Deficit"
            arc.items = []
            ["2008-12-31", "2009-12-31", "2010-12-31", "2011-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "37605000000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          ###########################################################################################
        end
      end

      if args[:sheet] == "google 10-k 2009-12-31 balance sheet"
        arc.items = []
        arc.children = []
        case args[:label]
          when "Assets"
            arc.children = []
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Assets Current")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Prepaid Revenue Share Expenses And Other Assets Noncurrent")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Deferred Tax Assets Net Noncurrent")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Other Long Term Investments")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Property Plant And Equipment Net")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Intangible Assets Net Excluding Goodwill")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Goodwill")
          when "Assets Current"
            arc.children = []
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Cash Cash Equivalents And Short Term Investments")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Accounts Receivable Net Current")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Deferred Tax Assets Net Current")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Income Taxes Receivable")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Prepaid Revenue Share Expenses And Other Assets")
          when "Cash Cash Equivalents And Short Term Investments"
            arc.children = []
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Cash And Cash Equivalents At Carrying Value")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Marketable Securities Current")
          ###########################################################################################
          when "Liabilities And Stockholders Equity"
            arc.children = []
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Liabilities Current")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Deferred Revenue Noncurrent")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Liability For Uncertain Tax Positions Noncurrent")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Deferred Tax Liabilities Noncurrent")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Other Liabilities Noncurrent")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Stockholders Equity")
          when "Liabilities Current"
            arc.children = []
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Accounts Payable Current")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Employee Related Liabilities Current")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Accrued Liabilities Current")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Accrued Revenue Share")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Deferred Revenue Current")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Accrued Income Taxes Current")
          when "Stockholders Equity"
            arc.children = []
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Convertible Preferred Stock Nonredeemable Or Redeemable Issuer Option Value")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Common Stock Value")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Additional Paid In Capital Common Stock")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Accumulated Other Comprehensive Income Loss Net Of Tax")
            arc.children.push self.CalculationArc(:sheet => args[:sheet],
                                                  :label => "Retained Earnings Accumulated Deficit")
          ###########################################################################################
          when "Cash And Cash Equivalents At Carrying Value"
            arc.items = []
            ["2006-12-31", "2007-12-31", "2008-12-31", "2009-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "10197588000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Marketable Securities Current"
            arc.items = []
            ["2006-12-31", "2007-12-31", "2008-12-31", "2009-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "14287187000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Accounts Receivable Net Current"
            arc.items = []
            ["2006-12-31", "2007-12-31", "2008-12-31", "2009-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "3178471000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Deferred Tax Assets Net Current"
            arc.items = []
            ["2006-12-31", "2007-12-31", "2008-12-31", "2009-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "644406000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Income Taxes Receivable"
            arc.items = []
            ["2006-12-31", "2007-12-31", "2008-12-31", "2009-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "23244000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Prepaid Revenue Share Expenses And Other Assets"
            arc.items = []
            ["2006-12-31", "2007-12-31", "2008-12-31", "2009-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "836062000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Prepaid Revenue Share Expenses And Other Assets Noncurrent"
            arc.items = []
            ["2006-12-31", "2007-12-31", "2008-12-31", "2009-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "416119000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Deferred Tax Assets Net Noncurrent"
            arc.items = []
            ["2006-12-31", "2007-12-31", "2008-12-31", "2009-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "262611000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Other Long Term Investments"
            arc.items = []
            ["2006-12-31", "2007-12-31", "2008-12-31", "2009-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "-128977000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Property Plant And Equipment Net"
            arc.items = []
            ["2006-12-31", "2007-12-31", "2008-12-31", "2009-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "4844610000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Intangible Assets Net Excluding Goodwill"
            arc.items = []
            ["2006-12-31", "2007-12-31", "2008-12-31", "2009-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "774938000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Goodwill"
            arc.items = []
            ["2006-12-31", "2007-12-31", "2008-12-31", "2009-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "4902565000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          ###########################################################################################
          when "Accounts Payable Current"
            arc.items = []
            ["2006-12-31", "2007-12-31", "2008-12-31", "2009-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "215867000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Employee Related Liabilities Current"
            arc.items = []
            ["2006-12-31", "2007-12-31", "2008-12-31", "2009-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "982482000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Accrued Liabilities Current"
            arc.items = []
            ["2006-12-31", "2007-12-31", "2008-12-31", "2009-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "570080000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Accrued Revenue Share"
            arc.items = []
            ["2006-12-31", "2007-12-31", "2008-12-31", "2009-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "693958000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Deferred Revenue Current"
            arc.items = []
            ["2006-12-31", "2007-12-31", "2008-12-31", "2009-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "285080000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Accrued Income Taxes Current"
            arc.items = []
            ["2006-12-31", "2007-12-31", "2008-12-31", "2009-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "0.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Deferred Revenue Noncurrent"
            arc.items = []
            ["2006-12-31", "2007-12-31", "2008-12-31", "2009-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "41618000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Liability For Uncertain Tax Positions Noncurrent"
            arc.items = []
            ["2006-12-31", "2007-12-31", "2008-12-31", "2009-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "1392468000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Deferred Tax Liabilities Noncurrent"
            arc.items = []
            ["2006-12-31", "2007-12-31", "2008-12-31", "2009-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "0.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Other Liabilities Noncurrent"
            arc.items = []
            ["2006-12-31", "2007-12-31", "2008-12-31", "2009-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "311001000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Convertible Preferred Stock Nonredeemable Or Redeemable Issuer Option Value"
            arc.items = []
            ["2006-12-31", "2007-12-31", "2008-12-31", "2009-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "0.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Common Stock Value"
            arc.items = []
            ["2006-12-31", "2007-12-31", "2008-12-31", "2009-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "318000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Additional Paid In Capital Common Stock"
            arc.items = []
            ["2006-12-31", "2007-12-31", "2008-12-31", "2009-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "15816738000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Accumulated Other Comprehensive Income Loss Net Of Tax"
            arc.items = []
            ["2006-12-31", "2007-12-31", "2008-12-31", "2009-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "105090000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          when "Retained Earnings Accumulated Deficit"
            arc.items = []
            ["2006-12-31", "2007-12-31", "2008-12-31", "2009-12-31"].each do |period_date|
              arc.items.push self.Item(:name => args[:label],
                                       :value => "20082078000.0",
                                       :decimals => "-3",
                                       :period => Date.parse(period_date)) 
            end
          ###########################################################################################
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
        when "google 10-k 2011-12-31 income statement"
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
        when "google 10-k 2009-12-31 income statement"
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

    def self.BalanceSheetCalculation(args = {})
      entity_details = {}
      title = ""
      role = ""
      href = ""
      arcs = []
      contexts = nil

      case args[:sheet]
        when "google 10-k 2011-12-31 balance sheet"
          entity_details = {"name"=>"Google Inc.", 
                            "ci_key"=>"0001288776", 
                            "doc_type"=>"10-K", 
                            "doc_end_date"=>"2011-12-31", 
                            "fiscal_end_date"=>"--12-31", 
                            "common_shares_outstanding"=>"67175694", 
                            "symbol"=>"GOOG"}
          title = "Statement Of Financial Position Classified"
          role = "http://www.google.com/taxonomy/role/StatementOfFinancialPositionClassified"
          href = "Role_StatementOfFinancialPositionClassified"

          arcs.push self.CalculationArc(:sheet => args[:sheet],
                                        :label => "Assets")
          arcs.push self.CalculationArc(:sheet => args[:sheet],
                                        :label => "Assets Current")
          arcs.push self.CalculationArc(:sheet => args[:sheet],
                                        :label => "Cash Cash Equivalents And Short Term Investments")
          arcs.push self.CalculationArc(:sheet => args[:sheet],
                                        :label => "Liabilities And Stockholders Equity")
          arcs.push self.CalculationArc(:sheet => args[:sheet],
                                        :label => "Liabilities Current")
          arcs.push self.CalculationArc(:sheet => args[:sheet],
                                        :label => "Stockholders Equity")

        when "google 10-k 2009-12-31 balance sheet"
          entity_details = {"name"=>"Google Inc.", 
                            "ci_key"=>"0001288776", 
                            "doc_type"=>"10-K", 
                            "doc_end_date"=>"2009-12-31", 
                            "fiscal_end_date"=>"--12-31", 
                            "common_shares_outstanding"=>"67175694", 
                            "symbol"=>"GOOG"}
          title = "Statement Of Financial Position Classified"
          role = "http://www.google.com/taxonomy/role/StatementOfFinancialPositionClassified"
          href = "Role_StatementOfFinancialPositionClassified"

          arcs.push self.CalculationArc(:sheet => args[:sheet],
                                        :label => "Assets")
          arcs.push self.CalculationArc(:sheet => args[:sheet],
                                        :label => "Assets Current")
          arcs.push self.CalculationArc(:sheet => args[:sheet],
                                        :label => "Cash Cash Equivalents And Short Term Investments")
          arcs.push self.CalculationArc(:sheet => args[:sheet],
                                        :label => "Liabilities And Stockholders Equity")
          arcs.push self.CalculationArc(:sheet => args[:sheet],
                                        :label => "Liabilities Current")
          arcs.push self.CalculationArc(:sheet => args[:sheet],
                                        :label => "Stockholders Equity")
      end

      calculation = Xbrlware::Linkbase::CalculationLinkbase::Calculation.new(entity_details, title, role, href, arcs, contexts)
      return FinModeling::BalanceSheetCalculation.new(taxonomy=nil, calculation)
    end
  end
end
