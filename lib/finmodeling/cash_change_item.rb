module FinModeling
  class CashChangeItem < String
    include HasStringClassifier

    BASE_FILENAME = File.join(FinModeling::BASE_PATH, "classifiers/cci_")
    TYPES         = [ :c, :i, :d, :f ]

    has_string_classifier(TYPES, CashChangeItem)

    def self.load_vectors_and_train
      self._load_vectors_and_train(BASE_FILENAME, FinModeling::CashChangeItem::TRAINING_VECTORS)
    end
  end
end
