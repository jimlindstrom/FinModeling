module FinModeling
  class NetIncomeCalculation < CompanyFilingCalculation

    def summary(period)
      s= super(period, type_to_flip="debit",  flip_total=true)
    
      s.rows[0..-2].each do |row|
        isi = FinModeling::IncomeStatementItem.new(row[:key])
        row[:type] = isi.classify
      end

      return s
    end
 
  end
end
