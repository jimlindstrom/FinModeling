module FinModeling
  class Rate
    def initialize(value)
      @value = value
    end

    def annualize(from_days=365, to_days=365)
      ((1.0 + @value)**(to_days.to_f/from_days.to_f)) - 1.0
    end
  end
end

