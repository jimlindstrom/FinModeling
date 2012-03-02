module FinModeling
  class AssetsItem < String

    TYPES = [ :oa, :fa ]

    @@classifiers = Hash[ *TYPES.zip(TYPES.map{ |x| NaiveBayes.new(:yes, :no) }).flatten ]

    def train(ai_type)
      raise TypeError if !TYPES.include?(ai_type)

      TYPES.each do |classifier_type|
        expected_outcome = (ai_type == classifier_type) ? :yes : :no
        @@classifiers[classifier_type].train(expected_outcome, *tokenize)
      end
    end

    def classification_estimates
      tokens = tokenize

      estimates = {}
      TYPES.each do |classifier_type|
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

    def self.load_vectors_and_train(vectors)
      vectors.each do |vector|
        ai = FinModeling::AssetsItem.new(vector[:item_string])
        ai.train(vector[:ai_type])
      end
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
