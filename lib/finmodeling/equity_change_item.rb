module FinModeling
  class EquityChangeItem < String
    include HasStringClassifier

    BASE_FILENAME = File.join(FinModeling::BASE_PATH, "classifiers/eci_")
    TYPES         = [ :share_issue, :share_repurch, :common_div, # transactions with shareholders
                      :net_income, :oci, :preferred_div ]        # comprehensive income

    # Notes:
    # 1. I need to go back to the EquityChangeCalculation and make sure that it's value mapping policy is accurate

    # Questions:
    # 1. what about transactions involving options, warrants, convertible debt?
    # 2. what about transactions involving restricted stock?
    # 3. what do I do with the stock-based compensation items?
    # 4. I'm not tagging dividends here. Should I be?
    # 5. None of these items has preferred stock. ... Find an example, so the classifier knows.

    has_string_classifier(TYPES, EquityChangeItem)

    def self.load_vectors_and_train
      self._load_vectors_and_train(BASE_FILENAME, FinModeling::EquityChangeItem::TRAINING_VECTORS)
    end
  end
end
