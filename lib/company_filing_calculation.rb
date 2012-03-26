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
      calc_summary.title = @calculation.label + " (#{@calculation.item_id})"

      calc_summary.rows = leaf_items(args).collect do |item| 
        CalculationRow.new(:key => item.pretty_name, 
                                             :vals => [ item.value(args[:mapping] )])
      end
    
      return calc_summary
    end

    protected

    def find_and_verify_calculation_arc(friendly_goal, label_regexes, id_regexes)
      calc = @calculation.arcs.find{ |x| x.label.downcase.gsub(/[^a-z ]/, '').matches_regexes?(label_regexes) }

      if calc.nil?
        summary_of_arcs = @calculation.arcs.map{ |x| "\"#{x.label}\"" }.join("; ")
        raise RuntimeError.new("Couldn't find #{friendly_goal} in: " + summary_of_arcs)
      end

      if !calc.item_id.matches_regexes?(id_regexes) 
        puts "Warning: #{friendly_goal} id is not recognized: #{calc.item_id}"
      end

      return calc
    end

  end
end
