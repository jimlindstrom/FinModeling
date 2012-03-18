module FinModeling

  module HasStringClassifier
    module ClassMethods
      @klasses     ||= []
      @classifiers ||= {}
      @item_klass  ||= nil

      def has_string_classifier(klasses, item_klass)
        @klasses     = klasses
        @item_klass  = item_klass
        @classifiers = Hash[ *klasses.zip(klasses.map{ |x| NaiveBayes.new(:yes, :no) }).flatten ]
      end
  
      def _load_vectors_and_train(base_filename, vectors)
        success = true
        @klasses.each do |cur_klass|
          filename = base_filename + cur_klass.to_s + ".db"
          success = success && File.exists?(filename)
          if success
            @classifiers[cur_klass] = NaiveBayes.load(filename)
          else
            @classifiers[cur_klass].db_filepath = filename
          end
        end
        return if success
  
        vectors.each do |vector|
          begin
            item = @item_klass.new(vector[:item_string])
            item.train(vector[:klass])
          rescue
            puts "\"#{vector[:item_string]}\" has a bogus klass: \"#{vector[:klass]}\""
          end
        end
  
        @klasses.each do |cur_klass|
          @classifiers[cur_klass].save
        end
      end

      def klasses
        @klasses
      end

      def classifiers
        @classifiers
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    def train(expected_klass)
      raise TypeError.new("#{expected_klass} is not in #{self.class.klasses}") if !self.class.klasses.include?(expected_klass)

      self.class.klasses.each do |cur_klass|
        is_expected_klass = (expected_klass == cur_klass) ? :yes : :no
        self.class.classifiers[cur_klass].train(is_expected_klass, *tokenize)
      end
    end

    def classification_estimates
      tokens = tokenize

      estimates = {}
      self.class.klasses.each do |cur_klass|
        ret = self.class.classifiers[cur_klass].classify(*tokens)
        result = {:klass=>ret[0], :confidence=>ret[1]}
        estimates[cur_klass] = (result[:klass] == :yes) ? result[:confidence] : -result[:confidence]
      end

      return estimates
    end

    def classify
      estimates = classification_estimates
      best_guess_klass = estimates.keys.sort{ |x,y| estimates[x] <=> estimates[y] }.last
      return best_guess_klass
    end

    def tokenize
      words = ["^"] + self.downcase.split(" ") + ["$"]

      tokens = [1, 2, 3].collect do |words_per_token|
        words.each_cons(words_per_token).to_a.map{|x| x.join(" ") }
      end
      return tokens.flatten
    end
  end

end
