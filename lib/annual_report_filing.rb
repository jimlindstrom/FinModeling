module FinModeling
  class AnnualReportFiling < CompanyFiling
    def balance_sheet
      calculations=@taxonomy.callb.calculation
      bal_sheet = calculations.find{ |x| (x.title.downcase =~ /statement.*financial.*position/) or
                                         (x.title.downcase =~ /balance.*sheet/) }
  
      return BalanceSheetCalculation.new(@taxonomy, bal_sheet)
    end
  end
end
