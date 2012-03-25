module Xbrlware

  class Context
    def write_constructor(file, context_name)
      period_str = "nil"
      case
        when !@period
        when self.period.is_instant?
          period_str = "Date.parse(\"#{self.period.value}\")"
        when self.period.is_duration?
          period_str = "{"
          period_str += "\"start_date\" => Date.parse(\"#{self.period.value["start_date"].to_s}\"),"
          period_str +=   "\"end_date\" => Date.parse(\"#{self.period.value[  "end_date"].to_s}\")"
          period_str += "}"
      end

      entity_str = "nil"
      case
        when !@entity || !@entity.segment
        else
          identifier_str = "\"#{@entity.identifier}\""
          segment_str = "{}"
          entity_str = "Xbrlware::Entity.new(identifier=#{identifier_str}, segment=#{segment_str})"
      end

      file.puts "#{context_name} = FinModeling::Factory.Context(:period => #{period_str}, :entity => #{entity_str})"
    end

    class Period
      def plus_n_months(n)
        new_value = @value
        n.times do
          case
            when is_instant?
              new_value = new_value.next_month
            when is_duration?
              new_value["start_date"] = new_value["start_date"].next_month
              new_value[  "end_date"] = new_value[  "end_date"].next_month
            else
              raise RuntimeError.new("not supported")
          end
        end
        Period.new(new_value)
      end

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
