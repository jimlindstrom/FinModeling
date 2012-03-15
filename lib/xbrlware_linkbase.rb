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
          self.arcs.each_with_index do |arc, index|
            arc_name = calc_name + "_arc#{index}"
            arc.write_constructor(file, arc_name)
            file.puts "#{calc_name}_args[:arcs].push #{arc_name}"
          end
          file.puts "#{calc_name} = FinModeling::Factory.Calculation(#{calc_name}_args)"
        end

        class CalculationArc
          def write_constructor(file, arc_name)
            file.puts "args = {}"
            file.puts "args[:item_id] = \"#{self.item_id}\""
            file.puts "args[:label] = \"#{self.label}\""
            file.puts "#{arc_name} = FinModeling::Factory.CalculationArc(args)"
            file.puts "#{arc_name}.items = []"
            self.items.each_with_index do |item, index|
              item_name = arc_name + "_item#{index}"
              item.write_constructor(file, item_name)
              file.puts "#{arc_name}.items.push #{item_name}"
            end
            file.puts "#{arc_name}.children = []"
            self.children.each_with_index do |child, index|
              child_name = arc_name + "_child#{index}"
              child.write_constructor(file, child_name)
              file.puts "#{arc_name}.children.push #{child_name}"
            end
          end
        end
      end
    end
  end

end
