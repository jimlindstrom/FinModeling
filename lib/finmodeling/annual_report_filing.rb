module FinModeling

  class AnnualReportFiling < CompanyFiling

    CONSTRUCTOR_PATH = File.join(FinModeling::BASE_PATH, "constructors/")
    SCHEMA_VERSION_ITEM = "@schema_version"
    CURRENT_SCHEMA_VERSION = 1.2
    # History:
    # 1.0: initial version
    # 1.1: added CFS to quarterly filings
    #      added disclosures
    #      renamed fake(.*)report to cached(.*)report
    # 1.2: added shareholders' equity statement

    def self.download(url)
      uid = url.split("/")[-2..-1].join('-').gsub(/\.[A-zA-z]*$/, '')
      constructor_file = CONSTRUCTOR_PATH + uid + '.rb'
      if File.exists?(constructor_file) && FinModeling::Config.caching_enabled?
        begin
          eval(File.read(constructor_file))
          #puts "info: annual report, cache hit. schema version: #{@schema_version}"
          return @filing if @schema_version == CURRENT_SCHEMA_VERSION
        rescue
          #puts "warn: annual report, cache hit. error eval'ing though."
        end
      end

      filing = super(url)

      FileUtils.mkdir_p(CONSTRUCTOR_PATH) if !File.exists?(CONSTRUCTOR_PATH)
      file = File.open(constructor_file, "w")
      filing.write_constructor(file, "@filing")
      file.close

      return filing
    end

    def balance_sheet
      if @balance_sheet.nil?
        calculations=@taxonomy.callb.calculation
        bal_sheet = calculations.find{ |x| (x.clean_downcased_title =~ /statement.*financial.*position/) or
                                           (x.clean_downcased_title =~ /statement.*financial.*condition/) or
                                           (x.clean_downcased_title =~ /balance.*sheet/) }
        if bal_sheet.nil?
          raise InvalidFilingError.new("Couldn't find balance sheet in: " + calculations.map{ |x| "\"#{x.clean_downcased_title}\"" }.join("; "))
        end
    
        @balance_sheet = BalanceSheetCalculation.new(bal_sheet)
      end
      return @balance_sheet
    end

    def income_statement
      if @income_stmt.nil?
        calculations=@taxonomy.callb.calculation
        inc_stmt = calculations.find{ |x| (x.clean_downcased_title =~ /statement(|s).*operations/) or
                                          (x.clean_downcased_title =~ /statement(|s).*of.*earnings/) or
                                          (x.clean_downcased_title =~ /statement(|s).*of.*(|net.*)income/) }
        if inc_stmt.nil?
          raise InvalidFilingError.new("Couldn't find income statement in: " + calculations.map{ |x| "\"#{x.clean_downcased_title}\"" }.join("; "))
        end
    
        @income_stmt = IncomeStatementCalculation.new(inc_stmt)
      end
      return @income_stmt
    end

    def cash_flow_statement
      if @cash_flow_stmt.nil?
        calculations=@taxonomy.callb.calculation
        cash_flow_stmt = calculations.find{ |x| (x.clean_downcased_title =~ /statement.*cash.*flows/) or
                                                (x.clean_downcased_title =~ /^cash flows$/) }
        if cash_flow_stmt.nil?
          raise InvalidFilingError.new("Couldn't find cash flow statement in: " + calculations.map{ |x| "\"#{x.clean_downcased_title}\"" }.join("; "))
        end
    
        @cash_flow_stmt = CashFlowStatementCalculation.new(cash_flow_stmt)
      end
      return @cash_flow_stmt
    end

    def has_a_shareholder_equity_statement?
      #puts "calculations: " + @taxonomy.callb.calculation.map{ |x| x.clean_downcased_title }.join(',')
      begin
        return !shareholder_equity_statement.nil?
      rescue
        return false
      end
    end

    def shareholder_equity_statement
      if @shareholder_equity_stmt.nil?
        calculations=@taxonomy.callb.calculation
        shareholder_equity_stmt = calculations.find{ |x| (x.clean_downcased_title =~ /statement(|s).*of.*(share|stock)holders(|').*equity(|.*and.*comprehensive|.*and.*other.*comprehensive|.*and.*comprehensive)(|.*income|.*loss|.*income.*loss|.*loss.*income)$/) ||
                                                         (x.clean_downcased_title =~ /statements.*of.*changes.*in.*shareholders.*equity/) }
        if shareholder_equity_stmt.nil?
          raise InvalidFilingError.new("Couldn't find shareholders' equity statement in: " + calculations.map{ |x| "\"#{x.clean_downcased_title}\"" }.join("; "))
        end
    
        @shareholder_equity_stmt = ShareholderEquityStatementCalculation.new(shareholder_equity_stmt)
      end
      return @shareholder_equity_stmt
    end

    def is_valid?
      puts "income statment is not valid" if !income_statement.is_valid?
      puts "balance sheet is not valid" if !balance_sheet.is_valid?
      #puts "cash flow statement is not valid" if !cash_flow_statement.is_valid?
      #return (income_statement.is_valid? && balance_sheet.is_valid? && cash_flow_statement.is_valid?)
      return (income_statement.is_valid? && balance_sheet.is_valid?)
    end

    def write_constructor(file, item_name)
      balance_sheet               .write_constructor(file, bs_name  = item_name + "_bs" )
      income_statement            .write_constructor(file, is_name  = item_name + "_is" )
      cash_flow_statement         .write_constructor(file, cfs_name = item_name + "_cfs")
      shareholder_equity_statement.write_constructor(file, ses_name = item_name + "_ses") if has_a_shareholder_equity_statement?
      ses_name = "nil" if !has_a_shareholder_equity_statement?

      names_of_discs = []
      disclosures.each_with_index do |disclosure, idx|
        name_of_disc = item_name + "_disc#{idx}"
        disclosure.write_constructor(file, name_of_disc)
        names_of_discs << name_of_disc
      end
      names_of_discs_str = "[" + names_of_discs.join(',') + "]"

      file.puts "#{SCHEMA_VERSION_ITEM} = #{CURRENT_SCHEMA_VERSION}" 

      file.puts "#{item_name} = FinModeling::CachedAnnualFiling.new(#{bs_name}, #{is_name}, #{cfs_name}, #{ses_name}, #{names_of_discs_str})"
    end
  end
end
