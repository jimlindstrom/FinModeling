module FinModeling
  class CalculationSummary
    attr_accessor :title, :rows

    KEY_WIDTH = 60
    VAL_WIDTH = 20
    def print
      puts @title
      @rows.each do |row|
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
  end

  class CompanyFilingCalculation

    def initialize(taxonomy, calculation)
      @taxonomy = taxonomy
      @calculation = calculation
    end
   
    def label
      @calculation.label
    end

    def periods
      PeriodArray.new(leaf_items.map{ |x| x.context.period }.sort{ |x,y| x.to_pretty_s <=> y.to_pretty_s }.uniq)
    end
  
    def leaf_items(period=nil)
      leaf_items_helper(@calculation, period)
    end

    def leaf_items_sum(period)
      sum = 0.0
      leaf_items(period).each do |item|
        #raise RuntimeError.new("can't find balance definition in #{item.inspect}") if item.def.nil?
        puts "can't find balance definition in #{item.inspect}" if item.def.nil?
        case 
          when item.def.nil?
            sum += item.value.to_f
          when item.def["xbrli:balance"] == "debit"  
            sum += item.value.to_f
          when item.def["xbrli:balance"] == "credit"  
            sum -= item.value.to_f
        end
      end
      return sum
    end

    def summary(period, type_to_flip, flip_total)
      calc_summary = CalculationSummary.new
      calc_summary.title = @calculation.label + " (#{@calculation.item_id})"

      calc_summary.rows = leaf_items(period).collect do |item| 
        { :key => item.pretty_name, :val => item.value_with_correct_sign(type_to_flip) }
      end
    
      total_val = leaf_items_sum(period)
      total_val = -total_val if flip_total
      calc_summary.rows.push({ :key => "Total", :val => total_val })

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
