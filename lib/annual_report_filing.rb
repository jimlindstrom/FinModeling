module FinModeling
  class AnnualReportFiling < CompanyFiling
    def balance_sheet
      calculations=@taxonomy.callb.calculation
      bal_sheet = calculations.find{ |x| (x.title.downcase =~ /statement.*financial.*position/) or
                                         (x.title.downcase =~ /statement.*financial.*condition/) or
                                         (x.title.downcase =~ /balance.*sheet/) }
      if bal_sheet.nil?
        raise RuntimeError.new("Couldn't find balance sheet in: " + calculations.map{ |x| "\"#{x.title}\"" }.join("; "))
      end
  
      return BalanceSheetCalculation.new(@taxonomy, bal_sheet)
    end

    def income_statement
      calculations=@taxonomy.callb.calculation
      inc_stmt = calculations.find{ |x| (x.title.downcase =~ /statement.*operations/) or
                                        (x.title.downcase =~ /statement[s]* of earnings/) or
                                        (x.title.downcase =~ /statement[s]* of income/) or
                                        (x.title.downcase =~ /statement[s]* of net income/) }
      if inc_stmt.nil?
        raise RuntimeError.new("Couldn't find income statement in: " + calculations.map{ |x| "\"#{x.title}\"" }.join("; "))
      end
  
      return IncomeStatementCalculation.new(@taxonomy, inc_stmt)
    end

    def is_valid?
      return (income_statement.is_valid? and balance_sheet.is_valid?)
    end
  end
end
