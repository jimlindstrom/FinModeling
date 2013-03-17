module FinModeling
  class QuarterlyReportFiling < AnnualReportFiling 

    def write_constructor(file, item_name)
      balance_sheet                 .write_constructor(file, bs_name  = item_name + "_bs" )
      income_statement              .write_constructor(file, is_name  = item_name + "_is" ) if has_an_income_statement?
      comprehensive_income_statement.write_constructor(file, cis_name = item_name + "_cis") if has_a_comprehensive_income_statement?
      cash_flow_statement           .write_constructor(file, cfs_name = item_name + "_cfs")

      is_name  = "nil" if !has_an_income_statement?
      cis_name = "nil" if !has_a_comprehensive_income_statement?
      ses_name = "nil" # because these only get reported in 10-k's?

      names_of_discs = []
      disclosures.each_with_index do |disclosure, idx|
        name_of_disc = item_name + "_disc#{idx}"
        disclosure.write_constructor(file, name_of_disc)
        names_of_discs << name_of_disc
      end
      names_of_discs_str = "[" + names_of_discs.join(',') + "]"

      file.puts "#{SCHEMA_VERSION_ITEM} = #{CURRENT_SCHEMA_VERSION}"

      file.puts "#{item_name} = FinModeling::CachedQuarterlyFiling.new(#{bs_name}, #{is_name}, #{cis_name}, #{cfs_name}, #{ses_name}, #{names_of_discs_str})"
    end

  end
end
