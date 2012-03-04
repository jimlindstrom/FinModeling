module FinModeling

  class MultiColumnCalculationSummary
    attr_accessor :title, :rows, :num_value_columns

    def total(col_idx)
      @rows.map{ |row| row[:vals][col_idx] }.inject(:+) || 0.0
    end

    def totals
      0.upto(@num_value_columns-1).collect do |col_idx|
        total(col_idx)
      end
    end

    KEY_WIDTH = 25
    VAL_WIDTH = 20
    MAX_DECIMALS = 4
    def print
      puts @title

      rows_with_total = @rows + [{ :key => "Total", :vals => self.totals }]
      rows_with_total.each do |row|
        justified_key = row[:key].fixed_width_left_justify(KEY_WIDTH)
    
        justified_vals = ""
        0.upto(@num_value_columns-1).collect do |col_idx|
          val_with_commas = row[:vals][col_idx].to_s.with_thousands_separators
          justified_vals += "  " + val_with_commas.cap_decimals(MAX_DECIMALS).fixed_width_right_justify(VAL_WIDTH) 
        end
    
        puts "\t" + justified_key + justified_vals
      end
      puts
    end

    def +(cs)
      raise RuntimeError.new("can't add CalculationSummaries with different numbers of rows") if @rows.length != cs.rows.length

      multics = MultiColumnCalculationSummary.new
      multics.title = self.title
      multics.num_value_columns = self.num_value_columns + 1
      multics.rows = []
      0.upto(@rows.length-1).each do |idx|
        new_row = { :key => @rows[idx][:key], :vals => [] }

        new_row[:vals] += @rows[idx][:vals]
        new_row[:vals].push cs.rows[idx][:val]

        multics.rows.push new_row
      end

      return multics
    end

  end

  class CalculationSummary
    attr_accessor :title, :rows

    def total
      @rows.map{ |row| row[:val] }.inject(:+) || 0.0
    end

    KEY_WIDTH = 60
    VAL_WIDTH = 20
    def print
      puts @title

      rows_with_total = @rows + [{ :key => "Total", :val => self.total }]
      rows_with_total.each do |row|
        justified_key = if !row[:type].nil?
          ("[#{row[:type]}] " + row[:key]).fixed_width_left_justify(KEY_WIDTH)
        else
          row[:key].fixed_width_left_justify(KEY_WIDTH)
        end
    
        val_with_commas = row[:val].to_s.with_thousands_separators
        justified_val = val_with_commas.fixed_width_right_justify(VAL_WIDTH) 
    
        puts "\t" + justified_key + "  " + justified_val
      end
      puts
    end

    def filter_by_type(type)
      cs = CalculationSummary.new
      cs.title = @title
      cs.rows = @rows.select{ |x| x[:type] == type }
      return cs
    end

    def +(cs)
      raise RuntimeError.new("can't add CalculationSummaries with different numbers of rows") if @rows.length != cs.rows.length

      multics = MultiColumnCalculationSummary.new
      multics.title = self.title
      multics.num_value_columns = 2
      multics.rows = []
      0.upto(@rows.length-1).each do |idx|
        new_row = { :key => @rows[idx][:key], :vals => [] }

        new_row[:vals].push @rows[idx][:val]
        new_row[:vals].push cs.rows[idx][:val]

        multics.rows.push new_row
      end

      return multics
    end
  end
end
