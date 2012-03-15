module FinModeling

  class MultiColumnCalculationSummaryRow
    attr_accessor :key, :type, :vals

    def initialize(args = {})
      @key  = args[:key] || ""
      @type = args[:type]
      @vals = args[:vals] || []
    end

    def print(key_width=18, max_decimals=4, val_width=12)
      justified_key = row.key.fixed_width_left_justify(key_width)
  
      justified_vals = ""
      0.upto(@num_value_columns-1).each do |col_idx|
        val_with_commas = row.vals[col_idx].to_s.with_thousands_separators
        justified_vals += "  " + val_with_commas.cap_decimals(max_decimals).fixed_width_right_justify(val_width) 
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

      if !@header_row.nil?
        justified_key = @header_row.key.fixed_width_left_justify(@key_width)
    
        justified_vals = ""
        0.upto(@num_value_columns-1).each do |col_idx|
          justified_vals += "  " + @header_row.vals[col_idx].fixed_width_right_justify(@val_width) 
        end
    
        puts "\t" + justified_key + justified_vals
      end

      rows_with_total = @rows
      rows_with_total << MultiColumnCalculationSummaryRow.new(:key => "Total", :vals => self.totals) if @totals_row_enabled

      rows_with_total.each { |row| row.print(@key_width, @max_decimals, @val_width) }
      puts
    end

    def +(cs)
      raise RuntimeError.new("can't add CalculationSummaries with different numbers of rows") if @rows.length != cs.rows.length

      multics = MultiColumnCalculationSummary.new
      multics.title = self.title
      multics.num_value_columns = self.num_value_columns + 1

      if !@header_row.nil?
        multics.header_row = MultiColumnCalculationSummaryRow.new(:key => @header_row.key, :vals => [])
        multics.header_row.vals += @header_row.vals
        multics.header_row.vals.push cs.header_row.val
      end

      multics.rows = []
      0.upto(@rows.length-1).each do |idx|
        new_row = MultiColumnCalculationSummaryRow.new(:key => @rows[idx].key, :vals => [])

        new_row.vals += @rows[idx].vals
        new_row.vals.push cs.rows[idx].val

        multics.rows.push new_row
      end

      return multics
    end

  end

end
