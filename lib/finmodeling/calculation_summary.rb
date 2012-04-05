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

    def num_vals
      @vals.length
    end

    def min_abs_val
      @vals.map{ |x| x.abs }.min
    end

    def scale_down_by(val)
      if val == :thousand
        @vals.map!{ |val| val / 1000.0 }
        @key += " ($KK)"
      elsif val == :million
        @vals.map!{ |val| val / 1000000.0 }
        @key += " ($MM)"
      else
        raise RuntimeError.new("Bogus val: #{val}")
      end
    end

    def insert_column_before(col_idx, val)
      @vals.insert(col_idx, val)
    end

    def print(key_width=18, max_decimals=4, val_width=12)
      type_and_key = ""
      type_and_key += "[#{@type}] " if @type
      type_and_key += @key
      key_lines = type_and_key.split_into_lines_shorter_than(key_width).map{ |line| line.fixed_width_left_justify(key_width) }
  
      justified_vals = ""
      @vals.each do |val|
        val_with_commas = val.to_s.with_thousands_separators
        justified_vals += "  " + val_with_commas.cap_decimals(max_decimals).fixed_width_right_justify(val_width) 
      end
   
      puts "\t" + key_lines.shift + justified_vals
      key_lines.each do |line|
        puts "\t " + line
      end
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
      @rows.map{ |row| row.num_vals }.max
    end

    def auto_scale!
      min_val = @rows.map{ |row| row.min_abs_val }.min
      if min_val >= 1000 && min_val < 100000
        @rows.each { |row| row.scale_down_by(:thousand) }
      elsif min_val >= 1000000
        @rows.each { |row| row.scale_down_by(:million) }
      end
    end

    def insert_column_before(col_idx, val=nil)
      @header_row.insert_column_before(col_idx, val) if @header_row
      @rows.each{ |row| row.insert_column_before(col_idx, val) }
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

    def +(other)
      raise RuntimeError.new("can't add a CalculationSummary to a #{other.class}") if !other.is_a?(CalculationSummary)
      multics = CalculationSummary.new
      multics.title = @title
      multics.rows = []

      if @header_row
        multics.header_row = CalculationHeader.new(
                               :key  => @header_row.key.dup, 
                               :vals => @header_row.vals.dup + other.header_row.vals.dup)
      end

      myrows  = @rows.dup
      itsrows = other.rows.dup
      while myrows.any? || itsrows.any?
        new_row = CalculationRow.new( :key  => "", :vals => [] )

        if    (myrows.any? && itsrows.empty?)
          new_row.key = myrows.first.key.dup
          new_row.vals += myrows.first.vals.dup
          new_row.vals += [""]*other.num_value_column

          myrows.shift

        elsif (myrows.empty? && itsrows.any?)
          new_row.key = itsrows.first.key.dup
          new_row.vals += [""]*num_value_columns
          new_row.vals += itsrows.first.vals.dup

          itsrows.shift

        elsif (myrows.first.key == itsrows.first.key)
          new_row.key = myrows.first.key.dup
          new_row.vals += myrows.first.vals.dup 
          new_row.vals += itsrows.first.vals.dup

          myrows.shift
          itsrows.shift

        elsif (myrows.first.key < itsrows.first.key)
          if myrow=myrows.find{|row| row.key == itsrows.first.key }
            new_row.key = myrows.first.key.dup
            new_row.vals += myrows.first.vals.dup
            new_row.vals += itsrows.first.vals.dup

            myrows.delete(myrow)
            itsrows.shift

          else
            new_row.key = itsrows.first.key.dup
            new_row.vals += [""]*num_value_columns
            new_row.vals += itsrows.first.vals.dup

            itsrows.shift
          end

        elsif (myrows.first.key > itsrows.first.key)
          if itsrow=itsrows.find{|row| row.key == myrows.first.key }
            new_row.key = myrows.first.key.dup
            new_row.vals += myrows.first.vals.dup 
            new_row.vals += itsrows.first.vals.dup

            myrows.shift
            itsrows.delete(itsrow)

          else
            new_row.key = myrows.first.key.dup
            new_row.vals += myrows.first.vals.dup
            new_row.vals += [""]*other.num_value_columns

            myrows.shift
          end

        end

        multics.rows << new_row
      end

      return multics
    end

  end

end
