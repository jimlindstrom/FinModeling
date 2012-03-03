module Xbrlware

  class Item
    def pretty_name
      self.name.gsub(/([a-z])([A-Z])/, '\1 \2')
    end

    def value_with_correct_sign(type_to_flip)
      if self.def.nil?
        #raise RuntimeError.new("item \"#{self.name}\" doesn't have xbrl:balance definition, which should be either 'credit' or 'debit'")
        puts "Warning: item \"#{self.name}\" doesn't have xbrl:balance definition, which should be either 'credit' or 'debit'"
        return self.value.to_f
      end

      return (self.def["xbrli:balance"] == type_to_flip) ? -self.value.to_f : self.value.to_f
    end
  end

  class Context
    class Period
      def to_pretty_s
        case
          when is_instant?
            return "#{@value}" 
          when is_duration?
            return "#{@value["start_date"]} to #{@value["end_date"]}" 
          else
            return to_s
        end
      end
    end
  end

end
