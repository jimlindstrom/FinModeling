
module FinModeling
  class Classifiers
    def self.train
      FinModeling::AssetsItem.load_vectors_and_train
      FinModeling::LiabsAndEquityItem.load_vectors_and_train
      FinModeling::IncomeStatementItem.load_vectors_and_train
      FinModeling::ComprehensiveIncomeStatementItem.load_vectors_and_train
      FinModeling::CashChangeItem.load_vectors_and_train
      FinModeling::EquityChangeItem.load_vectors_and_train
    end
  end
end
