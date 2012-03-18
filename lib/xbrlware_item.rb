module Xbrlware

  class ValueMapping
    attr_accessor :policy

    def initialize
      @unknown_classifier = nil

      @policy = { :credit  => :no_action,
                  :debit   => :no_action,
                  :unknown => :no_action } # FIXME: a classifier could be used here....
    end

    def value(name, defn, val)
      # we ignore 'name' in this implementation

      case @policy[defn]
        when :no_action then val
        when :flip then -val
      end
    end
  end

  class Item
    def pretty_name
      self.name.gsub(/([a-z])([A-Z])/, '\1 \2')
    end

    def write_constructor(file, item_name)
      item_context_name = item_name + "_context"
      if @context.nil?
        file.puts "#{item_context_name} = nil"
      else
        @context.write_constructor(file, item_context_name)
      end

      file.puts "#{item_name} = FinModeling::Factory.Item(:name     => \"#{@name}\","     +
                "                                         :decimals => \"#{@decimals}\"," +
                "                                         :context  => #{item_context_name}," +
                "                                         :value    => \"#{@value}\")"
      if !@def.nil? and !@def["xbrli:balance"].nil?
        file.puts "#{item_name}.def = { } if #{item_name}.def.nil?"
        file.puts "#{item_name}.def[\"xbrli:balance\"] = \"#{@def['xbrli:balance']}\""
      end
    end

    def print_tree(indent_count=0)
      output = "#{indent} #{@label}"

      @items.each do |item|
        period=item.context.period
        period_str = period.is_duration? ? "#{period.value["start_date"]} to #{period.value["end_date"]}" : "#{period.value}"
        output += " [#{item.def["xbrli:balance"]}]" unless item.def.nil?
        output += " (#{period_str}) = #{item.value}" unless item.nil?
      end
      puts indent + output

      @children.each { |child| child.print_tree(indent_count+1) }
    end

    def is_sub_leaf?
      @context.entity.segment
    end

    def value(mapping=nil)
      definition = case
        when @def.nil?                  then :unknown
        when @def["xbrli:balance"].nil? then :unknown
        else                                 @def["xbrli:balance"].to_sym
      end

      mapping = mapping || ValueMapping.new
      return mapping.value(pretty_name, definition, @value.to_f)
    end
  end

end
