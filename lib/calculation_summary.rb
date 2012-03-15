module FinModeling

  class CalculationSummaryRow
    attr_accessor :key, :type, :val

    def initialize(args = {})
      @key  = args[:key] || ""
      @type = args[:type]
      @val  = args[:val]
    end

    def print(key_width=60, val_width=20)
      justified_key = ""
      justified_key += "[#{@type}] " if @type
      justified_key += @key.fixed_width_left_justify(key_width)
  
      justified_val = @val.to_s.with_thousands_separators.fixed_width_right_justify(val_width) 
  
      puts "\t" + justified_key + "  " + justified_val
    end
  end

  class CalculationSummaryHeaderRow < CalculationSummaryRow
    def print(key_width=60, val_width=20)
      justified_key = @key.fixed_width_left_justify(@key_width)
      justified_val = @val.fixed_width_right_justify(@val_width) 
    
      puts "\t" + justified_key + "  " + justified_val
    end
  end

  class CalculationSummary
    attr_accessor :title, :header_row, :rows
    attr_accessor :key_width, :val_width

    def initialize
      @key_width = 60
      @val_width = 20
    end

    def total
      @rows.map{ |row| row.val }.inject(:+) || 0.0
    end

    def total_row
      CalculationSummaryRow.new(:key => "Total", :val => total)
    end

    def print
      puts @title

      all_rows = []
      all_rows << @header_row if @header_row
      all_rows += @rows
      all_rows << total_row
      all_rows.each { |row| row.print(@key_width, @val_width) }

      puts
    end

    def filter_by_type(type)
      cs = CalculationSummary.new
      cs.title = @title
      cs.rows = @rows.select{ |x| x.type == type }
      return cs
    end

    def +(cs)
      raise RuntimeError.new("can't add CalculationSummaries with different numbers of rows") if @rows.length != cs.rows.length

      multics = MultiColumnCalculationSummary.new
      multics.title = @title
      multics.num_value_columns = 2

      if @header_row
        multics.header_row = MultiColumnCalculationSummaryHeaderRow.new(:key => @header_row.key, :vals => [])
        multics.header_row.vals << @header_row.val
        multics.header_row.vals << cs.header_row.val
      end

      multics.rows = []
      0.upto(@rows.length-1).each do |idx|
        new_row = MultiColumnCalculationSummaryRow.new(:key => @rows[idx].key, :vals => [])
        new_row.vals << @rows[idx].val
        new_row.vals << cs.rows[idx].val

        multics.rows << new_row
      end

      return multics
    end
  end
end
