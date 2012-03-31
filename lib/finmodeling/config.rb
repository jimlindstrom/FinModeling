module FinModeling
  class Config
    @@caching_enabled = true
    def self.enable_caching
      @@caching_enabled = true
    end
    def self.disable_caching
      @@caching_enabled = false
    end
    def self.caching_enabled?
      @@caching_enabled
    end

    @@balance_detail_enabled = false
    def self.enable_balance_detail
      @@balance_detail_enabled = true
    end
    def self.disable_balance_detail
      @@balance_detail_enabled = false
    end
    def self.balance_detail_enabled?
      @@balance_detail_enabled
    end

    @@income_detail_enabled = false
    def self.enable_income_detail
      @@income_detail_enabled = true
    end
    def self.disable_income_detail
      @@income_detail_enabled = false
    end
    def self.income_detail_enabled?
      @@income_detail_enabled
    end
  end
end

