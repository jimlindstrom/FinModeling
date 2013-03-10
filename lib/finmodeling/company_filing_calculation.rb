module FinModeling
  class CompanyFilingCalculation
    attr_accessor :calculation # FIXME: get rid of this (it was just to enable testing)

    def initialize(calculation)
      @calculation = calculation
    end
   
    def label
      @calculation.label
    end

    def periods
      arr = leaf_items.map{ |x| x.context.period }
                      .sort{ |x,y| x.to_pretty_s <=> y.to_pretty_s }
                      .uniq
      PeriodArray.new(arr)
    end
  
    def leaf_items(args={})
      @calculation.leaf_items(args[:period])
    end

    def leaf_items_sum(args)
      leaves = leaf_items(:period => args[:period])
      values = leaves.map{ |item| item.value(args[:mapping]) }
      values.inject(:+)
    end

    def summary(args)
      calc_summary = CalculationSummary.new
      calc_summary.title = case
        when @calculation.instance_variable_defined?(:@title)   then @calculation.title
        when @calculation.instance_variable_defined?(:@label)   then @calculation.label
        else "[No title]"
      end
      calc_summary.title += case
        when @calculation.instance_variable_defined?(:@item_id) then " (#{@calculation.item_id})"
        when @calculation.instance_variable_defined?(:@role)    then " (#{@calculation.role   })"
        else ""
      end

      calc_summary.rows = leaf_items(args).collect do |item| 
        CalculationRow.new(:key => item.pretty_name, 
                           :vals => [ item.value(args[:mapping] )])
      end
    
      return calc_summary
    end

    def write_constructor(file, item_name)
      item_calc_name = item_name + "_calc"
      @calculation.write_constructor(file, item_calc_name)
      file.puts "#{item_name} = FinModeling::CompanyFilingCalculation.new(#{item_calc_name})"
    end

    protected

    def find_calculation_arc(friendly_goal, label_regexes, id_regexes)
      calc = @calculation.arcs.find{ |x| x.label.downcase.gsub(/[^a-z ]/, '').matches_regexes?(label_regexes) }

      if calc.nil?
        summary_of_arcs = @calculation.arcs.map{ |x| "\t\"#{x.label}\"" }.join("\n")
        raise InvalidFilingError.new("Couldn't find #{friendly_goal} in:\n" + summary_of_arcs + "\nTried: #{label_regexes.inspect}.")
      end

      if !calc.item_id.matches_regexes?(id_regexes) 
        puts "Warning: #{friendly_goal} id is not recognized: #{calc.item_id}"
      end

      return calc
    end

  end
end
