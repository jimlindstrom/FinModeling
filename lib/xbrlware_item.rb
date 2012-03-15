module Xbrlware

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

    def print_tree(indent_count=0)
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

    def value_with_correct_sign(type_to_flip)
      balance_defn = nil
      if self.def.nil?
        puts "Warning: item \"#{self.name}\" doesn't have xbrl:balance definition, which should be either 'credit' or 'debit'"
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

    BASE_FILENAME = "classifiers/item_"
    def self.load_vectors_and_train(vectors)
      success = true
      BALANCE_DEFNS.each do |classifier_type|
        filename = BASE_FILENAME + classifier_type.to_s + ".db"
        success = success && File.exists?(filename)
        if success
          @@classifiers[classifier_type] = NaiveBayes.load(filename)
        else
          @@classifiers[classifier_type].db_filepath = filename
        end
      end
      return if success

      vectors.each do |vector|
        item = Xbrlware::Item.new(instance=nil, name=vector[:item_string], context=nil, value="123456.0")
        item.train(vector[:balance_defn])
      end

      BALANCE_DEFNS.each do |classifier_type|
        @@classifiers[classifier_type].save
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

end
