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
  
    def leaf_items(period=nil)
      leaf_items_helper(@calculation, period)
    end

    def leaf_items_sum(period, type_to_flip="credit")
      values = leaf_items(period).map{ |item| item.value_with_correct_sign(type_to_flip) }
      values.inject(:+)
    end

    def summary(period, type_to_flip, flip_total)
      calc_summary = CalculationSummary.new
      calc_summary.title = @calculation.label + " (#{@calculation.item_id})"

      calc_summary.rows = leaf_items(period).collect do |item| 
        { :key => item.pretty_name, :val => item.value_with_correct_sign(type_to_flip) }
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

    private

    def leaf_items_helper(node, period)
      children = if node.class == Xbrlware::Linkbase::CalculationLinkbase::Calculation
        node.arcs
      else
        node.children
      end

      if children.empty?
        raise RuntimeError.new("#{node} (#{node.label}) has nil items!") if node.items.nil?
        items = node.items.select{ |x| x.context.entity.segment.nil? }
        # FIXME: I don't fully understand the '.context.entity.segment' 
        # attribute. It appears, though, that items that have this attribute are
        # sub-elements of other leaf nodes, broken out to provide more detail.
        if !period.nil?
          items = items.select{ |x| x.context.period.to_pretty_s == period.to_pretty_s }
        end
        return items
      end

      leaf_items = [ ]
      children.each do |child|
        leaf_items += leaf_items_helper(child, period)
      end
      return leaf_items
    end

  end
end
