module Xbrlware

  class Context
    def write_constructor(file, context_name)
      period_str = "nil"
      case
        when self.period.nil?
        when self.period.is_instant?
          period_str = "Date.parse(\"#{self.period.value}\")"
        when self.period.is_duration?
          period_str = "{"
          period_str += "\"start_date\" => Date.parse(\"#{self.period.value["start_date"].to_s}\"),"
          period_str += "\"end_date\" => Date.parse(\"#{self.period.value["end_date"].to_s}\")"
          period_str += "}"
      end

      entity_str = "nil"
      case
        when self.entity.nil? || self.entity.segment.nil?
        else
          identifier_str = "\"#{self.entity.identifier}\""
          segment_str = "{}"
          entity_str = "Xbrlware::Entity.new(identifier=#{identifier_str}, segment=#{segment_str})"
      end

      file.puts "#{context_name} = FinModeling::Factory.Context(:period => #{period_str}, :entity => #{entity_str})"
    end

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
