module Xbrlware

  class ValueMapping
    attr_accessor :policy

    def initialize
      @unknown_classifier = nil

      @policy = { :credit  => :no_action,
                  :debit   => :no_action,
                  :unknown => :no_action }
    end

    def value(name, defn, val)
      # we ignore 'name' in this implementation

      case @policy[defn]
        when :no_action then val
        when :flip then -val
      end
    end
  end

  class ValueMappingWithClassifier < ValueMapping
    BASE_FILENAME = "classifiers/item_"
    BALANCE_DEFNS = [ :credit, :debit ]

    @@classifiers = Hash[ *BALANCE_DEFNS.zip(BALANCE_DEFNS.map{ |x| NaiveBayes.new(:yes, :no) }).flatten ]

    def value(name, defn, val)
      defn = classify(name) if defn == :unknown

      case @policy[defn]
        when :no_action then val
        when :flip then -val
      end
    end

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

    private

    def train(name, balance_defn)
      raise TypeError if !BALANCE_DEFNS.include?(balance_defn)

      BALANCE_DEFNS.each do |classifier_type|
        expected_outcome = (balance_defn == classifier_type) ? :yes : :no
        @@classifiers[classifier_type].train(expected_outcome, *tokenize(name))
      end
    end

    def classification_estimates(name)
      tokens = tokenize(name)

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

    def tokenize(name)
      words = ["^"] + name.downcase.split(" ") + ["$"]

      tokens = [1, 2, 3].collect do |words_per_token|
        words.each_cons(words_per_token).to_a.map{|x| x.join(" ") }
      end
      return tokens.flatten
    end
  end

  class Item
    def pretty_name
      self.name.gsub(/([a-z])([A-Z])/, '\1 \2')
    end

    def write_constructor(file, item_name)
      item_context_name = item_name + "_context"
      if @context.nil?
        file.puts "#{item_context_name} = nil"
      else
        @context.write_constructor(file, item_context_name)
      end

      file.puts "#{item_name} = FinModeling::Factory.Item(:name     => \"#{@name}\","     +
                "                                         :decimals => \"#{@decimals}\"," +
                "                                         :context  => #{item_context_name}," +
                "                                         :value    => \"#{@value}\")"
      if !@def.nil? and !@def["xbrli:balance"].nil?
        file.puts "#{item_name}.def = { } if #{item_name}.def.nil?"
        file.puts "#{item_name}.def[\"xbrli:balance\"] = \"#{@def['xbrli:balance']}\""
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

    def is_sub_leaf?
      @context.entity.segment
    end

    def value(mapping=nil)
      definition = case
        when @def.nil?                  then :unknown
        when @def["xbrli:balance"].nil? then :unknown
        else                                 @def["xbrli:balance"].to_sym
      end

      mapping = mapping || ValueMapping.new
      return mapping.value(pretty_name, definition, @value.to_f)
    end
  end

end
