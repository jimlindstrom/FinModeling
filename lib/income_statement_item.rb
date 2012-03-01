module FinModeling
  class IncomeStatementItem < String

    ISI_TYPES = [ :or, :cogs, :oe, :oibt, :fibt, :tax, :ooiat, :fiat ]

    @@classifiers = Hash[ *ISI_TYPES.zip(ISI_TYPES.map{ |x| NaiveBayes.new(:yes, :no) }).flatten ]

    def train(isi_type)
      raise TypeError if !ISI_TYPES.include?(isi_type)

      ISI_TYPES.each do |classifier_type|
        expected_outcome = (isi_type == classifier_type) ? :yes : :no
        @@classifiers[classifier_type].train(expected_outcome, *tokenize)
      end
    end

    def classification_estimates
      tokens = tokenize

      estimates = {}
      ISI_TYPES.each do |classifier_type|
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

    def self.load_vectors_and_train(filename)
      f = File.open(filename)
      while line = f.gets
        if line =~ /^([A-Z]*) (.*)$/
          expected_outcome = $1.downcase.to_sym
          isi = FinModeling::IncomeStatementItem.new($2)
          isi.train(expected_outcome)
        end
      end
      f.close
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
