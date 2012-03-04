module FinModeling

  class CalculationSummary
    attr_accessor :title, :header_row, :rows
    attr_accessor :key_width, :val_width

    def initialize
      @key_width = 60
      @val_width = 20
    end

    def total
      @rows.map{ |row| row[:val] }.inject(:+) || 0.0
    end

    def print
      puts @title

      if !@header_row.nil?
        justified_key = @header_row[:key].fixed_width_left_justify(@key_width)
        justified_val = @header_row[:val].fixed_width_right_justify(@val_width) 
    
        puts "\t" + justified_key + "  " + justified_val
      end

      all_rows = @rows + [{ :key => "Total", :val => self.total }]
      all_rows.each do |row|
        justified_key = if !row[:type].nil?
          ("[#{row[:type]}] " + row[:key]).fixed_width_left_justify(@key_width)
        else
          row[:key].fixed_width_left_justify(@key_width)
        end
    
        val_with_commas = row[:val].to_s.with_thousands_separators
        justified_val = val_with_commas.fixed_width_right_justify(@val_width) 
    
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

      if !@header_row.nil?
        multics.header_row = { :key => @header_row[:key], :vals => [] }
        multics.header_row[:vals].push @header_row[:val]
        multics.header_row[:vals].push cs.header_row[:val]
      end

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
