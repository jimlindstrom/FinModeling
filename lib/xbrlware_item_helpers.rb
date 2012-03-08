module Xbrlware

  module Linkbase
    class Linkbase
      class Link
        def clean_downcased_title
          @title.gsub(/([A-Z]) ([A-Z])/, '\1\2').gsub(/([A-Z]) ([A-Z])/, '\1\2').downcase
        end
      end
    end
  end

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

  module DateUtil
    def self.days_between(date1=Date.today, date2=Date.today)
      begin
        date1=Date.parse(date1) if date1.is_a?(String)
        date2=Date.parse(date2) if date2.is_a?(String)
        (date1 > date2) ? (recent_date, past_date = date1, date2) : (recent_date, past_date = date2, date1)
        (recent_date - past_date).round
      rescue Exception => e
        0
      end
    end
  end
end
