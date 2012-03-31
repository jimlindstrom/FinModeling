module FinModeling
  class IncomeStatementItem < String
    include HasStringClassifier

    BASE_FILENAME = File.join(FinModeling::BASE_PATH, "classifiers/isi_")
    TYPES         = [ :or, :cogs, :oe, :oibt, :fibt, :tax, :ooiat, :fiat ]

    has_string_classifier(TYPES, IncomeStatementItem)

    def self.load_vectors_and_train
      self._load_vectors_and_train(BASE_FILENAME, FinModeling::IncomeStatementItem::TRAINING_VECTORS)
    end
  end
end
