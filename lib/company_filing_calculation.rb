module FinModeling
  class CompanyFilingCalculation
    attr_accessor :taxonomy, :calculation # FIXME: hide both of these

    def initialize(taxonomy, calculation)
      @taxonomy = taxonomy
      @calculation = calculation
    end
   
    def label
      @calculation.label
    end

    def periods
      @calculation.arcs[0].items.map{|x| x.context.period}.uniq.sort{|x,y| x.to_pretty_s <=> y.to_pretty_s }
    end
  
    def leaf_items(period)
      leaf_items_helper(@calculation, period)
    end

    def leaf_items_sum(period)
      sum = 0.0
      leaf_items(period).each do |item|
        raise RuntimeError.new("can't find balance definition in #{item.inspect}") if item.def.nil?
        case item.def["xbrli:balance"]
          when "debit"  
            sum += item.value.to_f
          when "credit"
            sum -= item.value.to_f
        end
      end
      return sum
    end

    def summarize(period, type_to_flip, flip_total)
      title = @calculation.label + " (#{@calculation.item_id})"

      rows = leaf_items(period).collect do |item| 
        [ item.pretty_name, item.value_with_correct_sign(type_to_flip) ]
      end
    
      total_val = leaf_items_sum(period)
      total_val = -total_val if flip_total
      rows.push ["Total", total_val ]

      print_pretty_summary(title, rows)
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
      if node.children.empty?
        return node.items.select{ |x| x.context.period.to_pretty_s == period.to_pretty_s }#.select{ |x| x.context.entity.segment.nil? }
        # FIXME: I don't fully understand the '.context.entity.segment' 
        # attribute. It appears, though, that items that have this attribute are
        # sub-elements of other leaf nodes, broken out to provide more detail.
      end

      leaf_items = [ ]
      node.children.each do |child|
        leaf_items += leaf_items_helper(child, period)
      end
      return leaf_items
    end

    KEY_WIDTH = 50
    VAL_WIDTH = 18
    def print_pretty_summary(title, rows)
      puts title
      rows.each do |key, val| 
        justified_key = key.fixed_width_left_justify(KEY_WIDTH)
    
        val_with_commas = val.to_s.with_thousands_separators
        justified_val = val_with_commas.fixed_width_right_justify(VAL_WIDTH) 
    
        puts "\t" + justified_key + "  " + justified_val
      end
      puts
    end

  end
end
