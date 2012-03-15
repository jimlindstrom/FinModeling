module FinModeling

  class FakeAnnualFiling 
    attr_accessor :balance_sheet, :income_statement
    def initialize(bs, is)
      @balance_sheet    = bs
      @income_statement = is
    end

    def is_valid?
      return (@income_statement.is_valid? and @balance_sheet.is_valid?)
    end
  end

  class FakeQuarterlyFiling < FakeAnnualFiling 
  end

  class CompanyFiling
    DOWNLOAD_PATH = "filings/"
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
      download_dir = DOWNLOAD_PATH + url.split("/")[-2]
      if !File.exists?(download_dir)
        dl = Edgar::HTMLFeedDownloader.new()
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
  
  end
end
