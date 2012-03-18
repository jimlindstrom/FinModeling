module FinModeling
  class ReformulatedCashFlowStatement
    attr_accessor :period

    def initialize(period, cash_change_summary)
      @period   = period

      @c = cash_change_summary.filter_by_type(:c) # just make this a member....
      @i = cash_change_summary.filter_by_type(:i)
      @d = cash_change_summary.filter_by_type(:d)
      @f = cash_change_summary.filter_by_type(:f)

      @i.rows << CalculationSummaryRow.new(:key => "",
                                           :type => :i,
                                           :val => cash_change_summary.total)
    end

    def -(ris2)
      cash_change_summary = FakeCashChangeSummary.new(self, ris2)
      return ReformulatedCashFlowStatement.new(@period, cash_change_summary)
    end

    def cash_from_operations
      @c
    end

    def cash_investments_in_operations
      @i
    end

    def payments_to_debtholders
      @d
    end

    def payments_to_stockholders
      @f
    end

    def free_cash_flow
      cs = FinModeling::CalculationSummary.new
      cs.title = "Free Cash Flow"
      cs.rows = [ CalculationSummaryRow.new(:key => "Cash from Operations (C)", :val => @c ),
                  CalculationSummaryRow.new(:key => "Cash Investment in Operations (I)", :val => @i ) ]
      return cs
    end

    def financing_flows
      cs = FinModeling::CalculationSummary.new
      cs.title = "Financing Flows"
      cs.rows = [ CalculationSummaryRow.new(:key => "Payments to debtholders (d)", :val => @d ),
                  CalculationSummaryRow.new(:key => "Payments to stockholders (F)", :val => @f ) ]
      return cs
    end

  end
end
