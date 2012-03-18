module FinModeling
  class AssetsItem < String
    include HasStringClassifier

    BASE_FILENAME = "classifiers/ai_"
    TYPES         = [ :oa, :fa ]

    has_string_classifier(TYPES, AssetsItem)

    def self.load_vectors_and_train
      self._load_vectors_and_train(BASE_FILENAME, FinModeling::AssetsItem::TRAINING_VECTORS)
    end
  end
end
