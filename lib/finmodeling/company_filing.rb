module FinModeling

  class CachedAnnualFiling 
    attr_accessor :balance_sheet, :income_statement, :cash_flow_statement, :shareholder_equity_statement, :disclosures
    def initialize(bs, is, cfs, ses, disclosures)
      @balance_sheet                = bs
      @income_statement             = is
      @cash_flow_statement          = cfs
      @shareholder_equity_statement = ses
      @disclosures                  = disclosures
    end

    def has_a_shareholder_equity_statement?
      !@shareholder_equity_statement.nil?
    end

    def is_valid?
      puts "income statment is not valid" if !@income_statement.is_valid?
      puts "balance sheet is not valid" if !@balance_sheet.is_valid?
      puts "cash flow statement is not valid" if !@cash_flow_statement.is_valid?
      return (@income_statement.is_valid? and @balance_sheet.is_valid? and @cash_flow_statement.is_valid?)
    end
  end

  class CachedQuarterlyFiling < CachedAnnualFiling 
  end

  class CompanyFiling
    DOWNLOAD_PATH = File.join(FinModeling::BASE_PATH, "filings/")
    attr_accessor :instance # FIXME: hide this
  
    def initialize(download_dir)
      instance_file = Xbrlware.file_grep(download_dir)["ins"]
      if instance_file.nil?
        raise "Filing (\"#{download_dir}\") has no instance files. No XBRL filing?"
      end
  
      @instance = Xbrlware.ins(instance_file)
      @taxonomy = @instance.taxonomy
      @taxonomy.init_all_lb
    end
  
    def self.download(url)
      FileUtils.mkdir_p(DOWNLOAD_PATH) if !File.exists?(DOWNLOAD_PATH)
      download_dir = DOWNLOAD_PATH + url.split("/")[-2]
      if !File.exists?(download_dir)
        dl = Xbrlware::Edgar::HTMLFeedDownloader.new()
        dl.download(url, download_dir)
      end
  
      return self.new(download_dir)
    end
  
    def print_presentations
      presentations = @taxonomy.prelb.presentation
      presentations.each { |pres| pres.print_tree }
    end
  
    def print_calculations
      calculations=@taxonomy.callb.calculation
      calculations.each { |calc| calc.print_tree }
    end

    def disclosures
      @taxonomy.callb
               .calculation
               .select{ |x| x.is_disclosure? }
               .map{ |x| CompanyFilingCalculation.new(x) }
    end
  
  end
end
