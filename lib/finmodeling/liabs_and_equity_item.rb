module FinModeling
  class LiabsAndEquityItem < String
    include HasStringClassifier

    BASE_FILENAME = "classifiers/laei_"
    TYPES         = [ :ol, :fl, :cse ]

    has_string_classifier(TYPES, LiabsAndEquityItem)

    def self.load_vectors_and_train
      self._load_vectors_and_train(BASE_FILENAME, FinModeling::AssetsItem::TRAINING_VECTORS)
    end
  end
end
