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
