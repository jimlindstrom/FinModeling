module FinModeling
  class AnnualReportFiling < CompanyFiling
    def balance_sheet
      calculations=@taxonomy.callb.calculation
      bal_sheet = calculations.find{ |x| (x.title.downcase =~ /statement.*financial.*position/) or
                                         (x.title.downcase =~ /statement.*financial.*condition/) or
                                         (x.title.downcase =~ /balance.*sheet/) }
      if bal_sheet.nil?
        raise RuntimeError.new("Couldn't find balance sheet in: " + calculations.map{ |x| "\"#{x.title}\"" }.join("; "))
      end
  
      return BalanceSheetCalculation.new(@taxonomy, bal_sheet)
    end
  end
end
