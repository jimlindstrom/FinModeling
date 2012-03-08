module FinModeling
  class AnnualReportFiling < CompanyFiling
    def balance_sheet
      if @balance_sheet.nil?
        calculations=@taxonomy.callb.calculation
        bal_sheet = calculations.find{ |x| (x.clean_downcased_title =~ /statement.*financial.*position/) or
                                           (x.clean_downcased_title =~ /statement.*financial.*condition/) or
                                           (x.clean_downcased_title =~ /balance.*sheet/) }
        if bal_sheet.nil?
          raise RuntimeError.new("Couldn't find balance sheet in: " + calculations.map{ |x| "\"#{x.clean_downcased_title}\"" }.join("; "))
        end
    
        @balance_sheet = BalanceSheetCalculation.new(@taxonomy, bal_sheet)
      end
      return @balance_sheet
    end

    def income_statement
      if @income_stmt.nil?
        calculations=@taxonomy.callb.calculation
        inc_stmt = calculations.find{ |x| (x.clean_downcased_title =~ /statement.*operations/) or
                                          (x.clean_downcased_title =~ /statement[s]*.*of.*earnings/) or
                                          (x.clean_downcased_title =~ /statement[s]*.*of.*income/) or
                                          (x.clean_downcased_title =~ /statement[s]*.*of.*net.*income/) }
        if inc_stmt.nil?
          raise RuntimeError.new("Couldn't find income statement in: " + calculations.map{ |x| "\"#{x.clean_downcased_title}\"" }.join("; "))
        end
    
        @income_stmt = IncomeStatementCalculation.new(@taxonomy, inc_stmt)
      end
      return @income_stmt
    end

    def is_valid?
      return (income_statement.is_valid? and balance_sheet.is_valid?)
    end
  end
end
