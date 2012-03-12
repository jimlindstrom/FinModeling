module FinModeling
  class QuarterlyReportFiling < AnnualReportFiling 

    def write_constructor(file, item_name)
      bs_name = item_name + "_bs"
      is_name = item_name + "_is"
      self.balance_sheet.write_constructor(file, bs_name)
      self.income_statement.write_constructor(file, is_name)

      # FIXME: this isn't the smartest way to go. It should have specs; it doesn't have full functionality
      file.puts "#{item_name} = FinModeling::FakeQuarterlyFiling.new(#{bs_name}, #{is_name})"
    end

  end
end
