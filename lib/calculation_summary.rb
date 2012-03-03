module FinModeling
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
  end
end
