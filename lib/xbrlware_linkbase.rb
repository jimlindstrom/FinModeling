module Xbrlware

  module Linkbase
    class Linkbase
      class Link
        def clean_downcased_title
          @title.gsub(/([A-Z]) ([A-Z])/, '\1\2').gsub(/([A-Z]) ([A-Z])/, '\1\2').downcase
        end
      end
    end

    class CalculationLinkbase
      class Calculation
        def write_constructor(file, calc_name)
          file.puts "#{calc_name}_args = {}"
          file.puts "#{calc_name}_args[:title] = \"#{self.title}\""
          file.puts "#{calc_name}_args[:arcs] = []"
          @arcs.each_with_index do |arc, index|
            arc_name = calc_name + "_arc#{index}"
            arc.write_constructor(file, arc_name)
            file.puts "#{calc_name}_args[:arcs].push #{arc_name}"
          end
          file.puts "#{calc_name} = FinModeling::Factory.Calculation(#{calc_name}_args)"
        end

        def print_tree(indent_count=0)
          indent = " " * indent_count
          puts indent + "Calc: #{@title} (#{@role})"

          @arcs.each { |arc| arc.print_tree(indent_count+1) }

          puts indent + "\n\n"
        end

        class CalculationArc
          def write_constructor(file, arc_name)
            file.puts "args = {}"
            file.puts "args[:item_id] = \"#{self.item_id}\""
            file.puts "args[:label] = \"#{self.label}\""
            file.puts "#{arc_name} = FinModeling::Factory.CalculationArc(args)"
            file.puts "#{arc_name}.items = []"
            @items.each_with_index do |item, index|
              item_name = arc_name + "_item#{index}"
              item.write_constructor(file, item_name)
              file.puts "#{arc_name}.items.push #{item_name}"
            end
            file.puts "#{arc_name}.children = []"
            @children.each_with_index do |child, index|
              child_name = arc_name + "_child#{index}"
              child.write_constructor(file, child_name)
              file.puts "#{arc_name}.children.push #{child_name}"
            end
          end

          def print_tree(indent_count=0)
            indent = " " * indent_count
            output = "#{indent} #{@label}"

            @items.each do |item|
              period=item.context.period
              period_str = period.is_duration? ? "#{period.value["start_date"]} to #{period.value["end_date"]}" : "#{period.value}"
              output += " [#{item.def["xbrli:balance"]}]" unless item.def.nil?
              output += " (#{period_str}) = #{item.value}" unless item.nil?
            end
            puts indent + output

            @children.each { |child| child.print_tree(indent_count+1) }
          end
        end
      end
    end

    class PresentationLinkbase
      class Presentation
        def print_tree(indent_count=0)
          indent = " " * indent_count
          puts indent + "Pres: #{@title} (#{@role})"

          @arcs.each { |arc| arc.print_tree(indent_count+1) }

          puts indent + "\n\n"
        end

        class PresentationArc
          def print_tree(indent_count=0)
            indent = " " * indent_count
            output = "#{indent} #{@label}"

            @items.each do |item|
              period=item.context.period
              period_str = period.is_duration? ? "#{period.value["start_date"]} to #{period.value["end_date"]}" : "#{period.value}"
              output += " [#{item.def["xbrli:balance"]}]" unless item.def.nil?
              output += " (#{period_str}) = #{item.value}" unless item.nil?
            end
            puts indent + output

            @children.each { |child| child.print_tree(indent_count+1) }
          end
        end
      end
    end
  end

end
