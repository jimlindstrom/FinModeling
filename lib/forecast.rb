module FinModeling
  class Forecast # FIXME: this doesn't feel like the right spot for these.  Make a self.forecast on re_is and re_bs?
    def self.next_reformulated_income_statement(policy, last_re_bs, last_re_is)
      operating_revenues = last_re_is.operating_revenues.total * (1.0 + policy.revenue_growth)
      income_from_sales_after_tax = operating_revenues * policy.sales_pm
      net_financing_income = last_re_bs.net_financial_assets.total * policy.fi_over_nfa
      comprehensive_income = income_from_sales_after_tax + net_financing_income

      SimplifiedReformulatedIncomeStatement.new(operating_revenues, income_from_sales_after_tax,
                                                net_financing_income, comprehensive_income)
    end

    def self.next_reformulated_balance_sheet(policy, last_re_bs, next_re_is)
      noa = next_re_is.operating_revenues.total / policy.sales_over_noa
      cse = last_re_bs.common_shareholders_equity.total / next_re_is.comprehensive_income.total
      nfa = cse - noa

      SimplifiedReformulatedBalanceSheet.new(noa, nfa, cse)
    end
  end
end
