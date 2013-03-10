module FinModeling
  class DebtCostOfCapital
    def self.calculate(opts)
      case 
      when  opts[:after_tax_cost] && !opts[:before_tax_cost] && !opts[:marginal_tax_rate]
        Rate.new(opts[:after_tax_cost].value)
      when !opts[:after_tax_cost] &&  opts[:before_tax_cost] &&  opts[:marginal_tax_rate]
        Rate.new(opts[:before_tax_cost].value * (1.0 - (opts[:marginal_tax_rate].value)))
      else
        raise ArgumentError
      end
    end
  end
end
