module FinModeling

  class ArrayWithStats < Array
    def mean
      return nil if empty?
      self.inject(:+) / self.length
    end

    def variance
      x_sqrd = self.map{ |x| x*x }
      x_sqrd_mean = (ArrayWithStats.new(x_sqrd).mean)
      x_sqrd_mean - (mean**2)
    end

    def linear_regression
      x = Array(0..(self.length-1)).to_scale
      y = self.to_scale
      Statsample::Regression.simple(x,y)
    end
  end

  class MultiColumnCalculationSummaryRow
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
      file.puts "#{item_name} = FinModeling::MultiColumnCalculationSummaryRow.new(args)"
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

    def write_constructor(file, item_name)
      file.puts "args = { }"
      file.puts "args[:key] = \"#{@key}\""
      file.puts "args[:vals] = [#{@vals.map{ |val| "\"#{val}\"" }.join(', ')}]"
      file.puts "#{item_name} = FinModeling::MultiColumnCalculationSummaryHeaderRow.new(args)"
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

    def write_constructor(file, item_name)
      file.puts "#{item_name} = FinModeling::MultiColumnCalculationSummary.new"
      file.puts "#{item_name}.title = \"#{@title}\""
      file.puts "#{item_name}.num_value_columns = #{@num_value_columns}"
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

    def +(param)
      if param.is_a?(CalculationSummary)
        plus_single_column(param)
      elsif param.is_a?(MultiColumnCalculationSummary)
        plus_multi_column(param)
      else
        raise RuntimeError.new("can't add a MultiColumnCalculationSummary to a #{param.class}")
      end
    end

    def plus_single_column(cs)
      raise RuntimeError.new("can't add CalculationSummaries with different numbers of rows") if @rows.length != cs.rows.length

      multics = MultiColumnCalculationSummary.new
      multics.title = @title
      multics.num_value_columns = @num_value_columns + 1

      if @header_row
        multics.header_row = MultiColumnCalculationSummaryHeaderRow.new(:key  => @header_row.key.dup, 
                                                                        :vals => @header_row.vals.dup)
        multics.header_row.vals << cs.header_row.val
      end

      multics.rows = []
      0.upto(@rows.length-1).each do |idx|
        new_row = MultiColumnCalculationSummaryRow.new(:key  => @rows[idx].key.dup, 
                                                       :vals => @rows[idx].vals.dup)

        new_row.vals << cs.rows[idx].val

        multics.rows << new_row
      end

      return multics
    end

    def plus_multi_column(mccs)
      raise RuntimeError.new("can't add CalculationSummaries with different numbers of rows") if @rows.length != mccs.rows.length

      multics = MultiColumnCalculationSummary.new
      multics.title = @title

      if @header_row
        multics.header_row = MultiColumnCalculationSummaryHeaderRow.new(
                               :key  => @header_row.key.dup, 
                               :vals => @header_row.vals.dup + mccs.header_row.vals.dup)
      end

      multics.rows = []
      0.upto(@rows.length-1).each do |idx|
        multics.rows << MultiColumnCalculationSummaryRow.new(
                          :key  => @rows[idx].key.dup, 
                          :vals => @rows[idx].vals.dup + mccs.rows[idx].vals.dup)
      end

      multics.num_value_columns = multics.rows.map{|row| row.vals.length}.max

      return multics
    end

  end

end
