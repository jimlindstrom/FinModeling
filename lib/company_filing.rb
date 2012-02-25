module FinModeling
  module CanBeWalkedRecursively
  
    def walk_subtree(elements, indent_count=0)
      elements.each_with_index do |element, index|
        indent=" " * indent_count
    
        output = "#{indent} #{element.label}"
        element.items.each do |item|
          period=item.context.period
          period_str = period.is_duration? ? "#{period.value["start_date"]} to #{period.value["end_date"]}" : "#{period.value}"
          output += " (#{period_str}) = #{item.value}" unless item.nil?
        end
    
        # Print to console
        puts output
    
        # If it has more elements, walk tree, recursively.
        #walk_subtree(element.children, indent_count+1) if element.has_children?
      end
    end
  
  end
  
  class CompanyFiling
    DOWNLOAD_PATH = "filings/"
  
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
      pres = @taxonomy.prelb.presentation
      pres.each do |pre|
        puts "Title is #{pre.title}"
        walk_subtree(pre.arcs)
        puts "\n\n"
      end
    end
  
    def print_calculations
      calculations=@taxonomy.callb.calculation
      calculations.each do |calc|
        puts "Title is #{calc.title}"
        walk_subtree(calc.arcs)
        puts "\n\n"
      end
    end
  
    private
  
    include CanBeWalkedRecursively
  
  end
end
