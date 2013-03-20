module FinModeling

  class AnnualReportFiling < CompanyFiling

    CONSTRUCTOR_PATH = File.join(FinModeling::BASE_PATH, "constructors/")
    SCHEMA_VERSION_ITEM = "@schema_version"
    CURRENT_SCHEMA_VERSION = 1.3
    # History:
    # 1.0: initial version
    # 1.1: added CFS to quarterly filings
    #      added disclosures
    #      renamed fake(.*)report to cached(.*)report
    # 1.2: added shareholders' equity statement
    # 1.3: added comprehensive income statement

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
        bal_sheet = calculations.find{ |x| ((x.clean_downcased_title =~ /statement.*financial.*position/) ||
                                            (x.clean_downcased_title =~ /statement.*financial.*condition/) ||
                                            (x.clean_downcased_title =~ /balance.*sheet/)) &&
                                           !(x.clean_downcased_title =~ /^balances included/) &&
                                           !(x.clean_downcased_title =~ /net of tax/) }
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
        inc_stmt = calculations.find{ |x| ((x.clean_downcased_title =~ /statement(|s).*operations/) ||
                                           (x.clean_downcased_title =~ /statement(|s).*of.*earnings/) ||
                                           (x.clean_downcased_title =~ /statement(|s).*of.*(|net.*)income/) ||
                                           (x.clean_downcased_title =~ /(|net.*)income.*statement(|s)/)) &&
                                          !(x.clean_downcased_title =~ /comprehensive/) &&
                                          !(x.clean_downcased_title =~ /schedule/) &&
                                          !(x.clean_downcased_title =~ /disclosure/) }
        if inc_stmt.nil?
          raise InvalidFilingError.new("Couldn't find income statement in: " + calculations.map{ |x| "\"#{x.clean_downcased_title}\"" }.join("; "))
        end
    
        @income_stmt = IncomeStatementCalculation.new(inc_stmt)
      end
      return @income_stmt
    end

    def has_an_income_statement?
      begin
        return income_statement ? true : false
      rescue
        return false
      end
    end

    def comprehensive_income_statement
      if @comprehensive_income_stmt.nil?
        calculations=@taxonomy.callb.calculation
        inc_stmt = calculations.find{ |x| ((x.clean_downcased_title =~ /statement.*operations/) ||
                                           (x.clean_downcased_title =~ /statement.*of.*earnings/) ||
                                           (x.clean_downcased_title =~ /statement.*of.*income/) ||
                                           (x.clean_downcased_title =~ /income.*statement/)) &&
                                          ( x.clean_downcased_title =~ /comprehensive/) }
        if inc_stmt.nil?
          raise InvalidFilingError.new("Couldn't find comprehensive income statement in: " + calculations.map{ |x| "\"#{x.clean_downcased_title}\"" }.join("; "))
        end
    
        @comprehensive_income_stmt = ComprehensiveIncomeStatementCalculation.new(inc_stmt)
      end
      return @comprehensive_income_stmt
    end

    def has_a_comprehensive_income_statement?
      begin
        return comprehensive_income_statement ? true : false
      rescue
        return false
      end
    end

    def cash_flow_statement
      if @cash_flow_stmt.nil?
        calculations=@taxonomy.callb.calculation
        cash_flow_stmt = calculations.find{ |x| (x.clean_downcased_title =~ /statement.*cash.*flow(|s)/) ||
                                                (x.clean_downcased_title =~ /^cash flow(|s)$/) }
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
      puts "balance sheet is not valid" if !balance_sheet.is_valid?
      puts "income statment is not valid" if has_an_income_statement? && !income_statement.is_valid?
      puts "comprehensive income statment is not valid" if has_a_comprehensive_income_statement? && !comprehensive_income_statement.is_valid?
      #puts "cash flow statement is not valid" if !cash_flow_statement.is_valid?

      return false if !balance_sheet.is_valid?
      return false if has_an_income_statement? && !income_statement.is_valid?
      return false if has_a_comprehensive_income_statement? && !comprehensive_income_statement.is_valid?
      #return false if !cash_flow_statement.is_valid? # FIXME: why can't we enable this?
      return true
    end

    def write_constructor(file, item_name)
      balance_sheet                 .write_constructor(file, bs_name  = item_name + "_bs" )
      income_statement              .write_constructor(file, is_name  = item_name + "_is" ) if has_an_income_statement?
      comprehensive_income_statement.write_constructor(file, cis_name = item_name + "_cis") if has_a_comprehensive_income_statement?
      cash_flow_statement           .write_constructor(file, cfs_name = item_name + "_cfs")
      shareholder_equity_statement  .write_constructor(file, ses_name = item_name + "_ses") if has_a_shareholder_equity_statement?
      is_name  = "nil" if !has_an_income_statement?
      cis_name = "nil" if !has_a_comprehensive_income_statement?
      ses_name = "nil" if !has_a_shareholder_equity_statement?

      names_of_discs = []
      disclosures.each_with_index do |disclosure, idx|
        name_of_disc = item_name + "_disc#{idx}"
        disclosure.write_constructor(file, name_of_disc)
        names_of_discs << name_of_disc
      end
      names_of_discs_str = "[" + names_of_discs.join(',') + "]"

      file.puts "#{SCHEMA_VERSION_ITEM} = #{CURRENT_SCHEMA_VERSION}" 

      file.puts "#{item_name} = FinModeling::CachedAnnualFiling.new(#{bs_name}, #{is_name}, #{cis_name}, #{cfs_name}, #{ses_name}, #{names_of_discs_str})"
    end
  end
end
