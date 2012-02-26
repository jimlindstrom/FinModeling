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
      @calculation.arcs[0].items.map{|x| x.context.period}.uniq.sort{|x,y| x.to_s <=> y.to_s }
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

    private

    def leaf_items_helper(node, period)
      if node.children.empty?
        return node.items.select{ |x| x.context.period.to_s == period.to_s }.select{ |x| x.context.entity.segment.nil? }
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
  end
end
