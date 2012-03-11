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
    
        @balance_sheet = BalanceSheetCalculation.new(bal_sheet)
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
    
        @income_stmt = IncomeStatementCalculation.new(inc_stmt)
      end
      return @income_stmt
    end

    def is_valid?
      return (income_statement.is_valid? and balance_sheet.is_valid?)
    end

    def write_constructor(file, item_name)
      bs_name = item_name + "_bs"
      is_name = item_name + "_is"
      self.balance_sheet.write_constructor(file, bs_name)
      self.income_statement.write_constructor(file, is_name)

      # FIXME: this isn't the smartest way to go:
      # 1. it doesn't have full AnnualReport functionality
      # 2. it should have specs, and be regular- (non-meta-) programmed
      file.puts "module FinModeling"
      file.puts "  class FakeStatement"
      file.puts "    attr_accessor :balance_sheet, :income_statement"
      file.puts "    def initialize(bs, is)"
      file.puts "      @balance_sheet    = bs"
      file.puts "      @income_statement = is"
      file.puts "    end"
      file.puts "    def is_valid?"
      file.puts "      return (@income_statement.is_valid? and @balance_sheet.is_valid?)"
      file.puts "    end"
      file.puts "  end"
      file.puts "end"

      file.puts "#{item_name} = FinModeling::FakeStatement.new(#{bs_name}, #{is_name})"
    end
  end
end
