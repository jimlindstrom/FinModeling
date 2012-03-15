module FinModeling

  class MultiColumnCalculationSummaryRow
    attr_accessor :key, :type, :vals

    def initialize(args = {})
      @key  = args[:key] || ""
      @type = args[:type]
      @vals = args[:vals] || []
    end

    def print(key_width=18, max_decimals=4, val_width=12)
      justified_key = @key.fixed_width_left_justify(key_width)
  
      justified_vals = ""
      @vals.each do |val|
        val_with_commas = val.to_s.with_thousands_separators
        justified_vals += "  " + val_with_commas.cap_decimals(max_decimals).fixed_width_right_justify(val_width) 
      end
   
      puts "\t" + justified_key + justified_vals
    end
  end

  class MultiColumnCalculationSummaryHeaderRow < MultiColumnCalculationSummaryRow
    def print(key_width=18, max_decimals=4, val_width=12)
      justified_key = @key.fixed_width_left_justify(key_width)
  
      justified_vals = ""
      @vals.each do |val|
        justified_vals += "  " + val.fixed_width_right_justify(val_width) 
      end
  
      puts "\t" + justified_key + justified_vals
    end
  end

  class MultiColumnCalculationSummary
    attr_accessor :title, :header_row, :rows, :num_value_columns
    attr_accessor :key_width, :val_width, :max_decimals, :totals_row_enabled

    def initialize
      @key_width = 18
      @val_width = 12
      @max_decimals = 4
      @totals_row_enabled = true
    end

    def total(col_idx)
      @rows.map{ |row| row.vals[col_idx] }.inject(:+) || 0.0
    end

    def totals
      0.upto(@num_value_columns-1).collect do |col_idx|
        total(col_idx)
      end
    end

    def print
      puts @title

      rows = []
      rows << @header_row if @header_row
      rows += @rows
      rows << MultiColumnCalculationSummaryRow.new(:key => "Total", :vals => @totals) if @totals_row_enabled
      rows.each { |row| row.print(@key_width, @max_decimals, @val_width) }

      puts
    end

    def +(cs)
      raise RuntimeError.new("can't add CalculationSummaries with different numbers of rows") if @rows.length != cs.rows.length

      multics = MultiColumnCalculationSummary.new
      multics.title = @title
      multics.num_value_columns = @num_value_columns + 1

      if @header_row
        multics.header_row = MultiColumnCalculationSummaryHeaderRow.new(:key  => @header_row.key, 
                                                                        :vals => @header_row.vals)
        multics.header_row.vals << cs.header_row.val
      end

      multics.rows = []
      0.upto(@rows.length-1).each do |idx|
        new_row = MultiColumnCalculationSummaryRow.new(:key  => @rows[idx].key, 
                                                       :vals => @rows[idx].vals)

        new_row.vals << cs.rows[idx].val

        multics.rows << new_row
      end

      return multics
    end

  end

end
