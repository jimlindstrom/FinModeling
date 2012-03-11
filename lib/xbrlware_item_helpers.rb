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

    def write_constructor(file, item_name)
      item_context_name = item_name + "_context"
      if self.context.nil?
        file.puts "#{item_context_name} = nil"
      else
        self.context.write_constructor(file, item_context_name)
      end

      file.puts "#{item_name} = FinModeling::Factory.Item(:name     => \"#{self.name}\","     +
                "                                         :decimals => \"#{self.decimals}\"," +
                "                                         :context  => #{item_context_name}," +
                "                                         :value    => \"#{self.value}\")"
      if !self.def.nil? and !self.def["xbrli:balance"].nil?
        file.puts "#{item_name}.def = { } if #{item_name}.def.nil?"
        file.puts "#{item_name}.def[\"xbrli:balance\"] = \"#{self.def['xbrli:balance']}\""
      end
    end

    def value_with_correct_sign(type_to_flip)
      balance_defn = nil
      if self.def.nil?
        #puts "Warning: item \"#{self.name}\" doesn't have xbrl:balance definition, which should be either 'credit' or 'debit'"
        balance_defn = self.default_balance_defn.to_s
      else
        balance_defn = self.def["xbrli:balance"]
      end

      return (balance_defn == type_to_flip) ? -self.value.to_f : self.value.to_f
    end

    BALANCE_DEFNS = [ :credit, :debit ]

    @@classifiers = Hash[ *BALANCE_DEFNS.zip(BALANCE_DEFNS.map{ |x| NaiveBayes.new(:yes, :no) }).flatten ]

    def train(balance_defn)
      raise TypeError if !BALANCE_DEFNS.include?(balance_defn)

      BALANCE_DEFNS.each do |classifier_type|
        expected_outcome = (balance_defn == classifier_type) ? :yes : :no
        @@classifiers[classifier_type].train(expected_outcome, *tokenize)
      end
    end

    def classification_estimates
      tokens = tokenize

      estimates = {}
      BALANCE_DEFNS.each do |classifier_type|
        ret = @@classifiers[classifier_type].classify(*tokens)
        result = {:outcome=>ret[0], :confidence=>ret[1]}
        estimates[classifier_type] = (result[:outcome] == :yes) ? result[:confidence] : -result[:confidence]
      end

      return estimates
    end

    def classify
      estimates = classification_estimates
      best_guess_type = estimates.keys.sort{ |x,y| estimates[x] <=> estimates[y] }.last
      return best_guess_type
    end
    def default_balance_defn
      classify
    end

    def self.load_vectors_and_train(vectors)
      vectors.each do |vector|
        item = Xbrlware::Item.new(instance=nil, name=vector[:item_string], context=nil, value="123456.0")
        item.train(vector[:balance_defn])
      end
    end

    def tokenize
      words = ["^"] + self.pretty_name.downcase.split(" ") + ["$"]

      tokens = [1, 2, 3].collect do |words_per_token|
        words.each_cons(words_per_token).to_a.map{|x| x.join(" ") }
      end
      return tokens.flatten
    end
  end

  module Linkbase
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
      end
    end
  end

  module Linkbase
    class CalculationLinkbase
      class Calculation
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
      file.puts "#{context_name} = FinModeling::Factory.Context(:period => #{period_str})"
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
