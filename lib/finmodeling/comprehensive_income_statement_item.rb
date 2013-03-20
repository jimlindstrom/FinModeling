module FinModeling
  class ComprehensiveIncomeStatementItem < String
    include HasStringClassifier

    BASE_FILENAME = File.join(FinModeling::BASE_PATH, "classifiers/cisi_")
    TYPES         = [ :or, :cogs, :oe, :oibt, :fibt, :tax, :ooiat, :fiat, :ni, :ooci, :ooci_nci, :foci, :unkoci ]
    # same as in IncomeStatementItem, plus four new types:
    # ni (net income -- optional, for when it is rolled up, versus (more typically) presented in the same detail as in the income statement)
    # ooci (operating other comperhensive income)
    # ooci_nci (operating other comperhensive income - non-controling interest)
    # foci (financial other comperhensive income)
    # unkoci (unknown (either operating or financial) other comperhensive income)

    has_string_classifier(TYPES, ComprehensiveIncomeStatementItem)

    def self.load_vectors_and_train
      self._load_vectors_and_train(BASE_FILENAME, FinModeling::ComprehensiveIncomeStatementItem::TRAINING_VECTORS)
    end
  end
end
