module FinModeling

  class CalculationRow
    attr_accessor :key, :type, :vals

    def initialize(args = {})
      @key  = args[:key] || ""
      @type = args[:type]
      @vals = args[:vals] || []
    end

    def valid_vals
      ArrayWithStats.new(@vals.select{ |val| !val.nil? })
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

    def write_constructor(file, item_name)
      file.puts "args = { }"
      file.puts "args[:key] = \"#{@key}\""
      file.puts "args[:type] = \"#{@type}\""
      file.puts "args[:vals] = [#{@vals.join(', ')}]"
      file.puts "#{item_name} = FinModeling::CalculationRow.new(args)"
    end
  end

  class CalculationHeader < CalculationRow
    def print(key_width=18, max_decimals=4, val_width=12)
      justified_key = @key.fixed_width_left_justify(key_width)
  
      justified_vals = ""
      @vals.each do |val|
        justified_vals += "  " + val.fixed_width_right_justify(val_width) 
      end
  
      puts "\t" + justified_key + justified_vals
    end

    def write_constructor(file, item_name)
      file.puts "args = { }"
      file.puts "args[:key] = \"#{@key}\""
      file.puts "args[:vals] = [#{@vals.map{ |val| "\"#{val}\"" }.join(', ')}]"
      file.puts "#{item_name} = FinModeling::CalculationHeader.new(args)"
    end
  end

  class CalculationSummary
    attr_accessor :title, :header_row, :rows
    attr_accessor :key_width, :val_width, :max_decimals, :totals_row_enabled

    def initialize
      @key_width = 18
      @val_width = 12
      @max_decimals = 4
      @totals_row_enabled = true
    end

    def num_value_columns
      @rows.map{ |row| row.vals.length }.max
    end

    def auto_scale!
      min_val = @rows.map{ |row| row.vals.map{ |x| x.abs }.min }.min
      if min_val >= 1000 && min_val < 100000
        @rows.each { |row| row.vals.map!{ |val| val /    1000.0 } }
        @rows.each { |row| row.key += " ($KK)" }
      elsif min_val >= 1000000
        @rows.each { |row| row.vals.map!{ |val| val / 1000000.0 } }
        @rows.each { |row| row.key += " ($MM)" }
      end
    end

    def total(col_idx=0)
      @rows.map{ |row| row.vals[col_idx] }.inject(:+) || 0.0
    end

    def totals
      return [] if num_value_columns.nil?
      0.upto(num_value_columns-1).map { |col_idx| total(col_idx) }
    end

    def print
      puts @title

      rows = []
      rows << @header_row if @header_row
      rows += @rows
      rows << CalculationRow.new(:key => "Total", :vals => totals) if @totals_row_enabled
      rows.each { |row| row.print(@key_width, @max_decimals, @val_width) }

      puts
    end

    def filter_by_type(type)
      cs = CalculationSummary.new
      cs.title = @title
      cs.rows = @rows.select{ |x| x.type == type }
      return cs
    end

    def write_constructor(file, item_name)
      file.puts "#{item_name} = FinModeling::CalculationSummary.new"
      file.puts "#{item_name}.title = \"#{@title}\""
      file.puts "#{item_name}.key_width = #{@key_width}"
      file.puts "#{item_name}.val_width = #{@val_width}"
      file.puts "#{item_name}.max_decimals = #{@max_decimals}"
      file.puts "#{item_name}.totals_row_enabled = #{@totals_row_enabled}"

      if @header_row
        header_row_item_name = item_name + "_header_row"
        @header_row.write_constructor(file, header_row_item_name)
        file.puts "#{item_name}.header_row = #{header_row_item_name}"
      end

      row_item_names = []
      @rows.each_with_index do |row, index|
        row_item_name = item_name + "_row#{index}"
        row.write_constructor(file, row_item_name)
        row_item_names << row_item_name
      end
      file.puts "#{item_name}.rows = [#{row_item_names.join(',')}]"
    end

    def +(mccs)
      raise RuntimeError.new("can't add a CalculationSummary to a #{mccs.class}") if !mccs.is_a?(CalculationSummary)
      if @rows.length != mccs.rows.length
        raise RuntimeError.new("can't add CalculationSummaries with different numbers of rows.\n" +
                               "1st summary's keys: " +     @rows.map{ |x| x.key }.join(',') + "\n" + 
                               "2nd summary's keys: " + mccs.rows.map{ |x| x.key }.join(',') ) 
      end
      if mccs.rows.map{ |x| x.key } != @rows.map{ |x| x.key }
        raise RuntimeError.new("can't add CalculationSummaries with different keys.\n" +
                               "1st summary's keys: " +     @rows.map{ |x| x.key }.join(',') + "\n" + 
                               "2nd summary's keys: " + mccs.rows.map{ |x| x.key }.join(',') ) 
      end

      multics = CalculationSummary.new
      multics.title = @title

      if @header_row
        multics.header_row = CalculationHeader.new(
                               :key  => @header_row.key.dup, 
                               :vals => @header_row.vals.dup + mccs.header_row.vals.dup)
      end

      multics.rows = []
      0.upto(@rows.length-1).each do |idx|
        multics.rows << CalculationRow.new(
                          :key  => @rows[idx].key.dup, 
                          :vals => @rows[idx].vals.dup + mccs.rows[idx].vals.dup)
      end

      return multics
    end

  end

end
