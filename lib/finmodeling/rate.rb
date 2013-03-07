module FinModeling
  class Rate
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def annualize(from_days=365, to_days=365)
      ((1.0 + @value)**(to_days.to_f/from_days.to_f)) - 1.0
    end

    def yearly_to_quarterly
      annualize(from_days=365.0, to_days=365.0/4.0)
    end

    def quarterly_to_yearly
      annualize(from_days=365.0/4.0, to_days=365.0)
    end
  end

  class DiscountRate < Rate
    def annualize(from_days=365, to_days=365)
      @value**(to_days.to_f/from_days.to_f)
    end
  end
end

