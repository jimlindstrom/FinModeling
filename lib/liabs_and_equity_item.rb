module FinModeling
  class LiabsAndEquityItem < String

    TYPES = [ :ol, :fl, :cse ]

    @@classifiers = Hash[ *TYPES.zip(TYPES.map{ |x| NaiveBayes.new(:yes, :no) }).flatten ]

    def train(laei_type)
      raise TypeError if !TYPES.include?(laei_type)

      TYPES.each do |classifier_type|
        expected_outcome = (laei_type == classifier_type) ? :yes : :no
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

    BASE_FILENAME = "classifiers/laei_"
    def self.load_vectors_and_train(vectors)
      success = true
      TYPES.each do |classifier_type|
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
        laei = FinModeling::LiabsAndEquityItem.new(vector[:item_string])
        laei.train(vector[:laei_type])
      end

      TYPES.each do |classifier_type|
        @@classifiers[classifier_type].save
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
