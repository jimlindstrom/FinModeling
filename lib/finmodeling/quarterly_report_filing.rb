module FinModeling
  class QuarterlyReportFiling < AnnualReportFiling 

    def write_constructor(file, item_name)
      balance_sheet.write_constructor(      file, bs_name  = item_name + "_bs")
      income_statement.write_constructor(   file, is_name  = item_name + "_is")
      cash_flow_statement.write_constructor(file, cfs_name = item_name + "_cfs")
      ses_name = "nil"

      names_of_discs = []
      disclosures.each_with_index do |disclosure, idx|
        name_of_disc = item_name + "_disc#{idx}"
        disclosure.write_constructor(file, name_of_disc)
        names_of_discs << name_of_disc
      end
      names_of_discs_str = "[" + names_of_discs.join(',') + "]"

      file.puts "#{SCHEMA_VERSION_ITEM} = #{CURRENT_SCHEMA_VERSION}"

      file.puts "#{item_name} = FinModeling::CachedQuarterlyFiling.new(#{bs_name}, #{is_name}, #{cfs_name}, #{ses_name}, #{names_of_discs_str})"
    end

  end
end
