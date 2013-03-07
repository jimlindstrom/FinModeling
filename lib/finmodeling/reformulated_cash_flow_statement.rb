module FinModeling
  class ReformulatedCashFlowStatement
    attr_accessor :period

    def initialize(period, cash_change_summary)
      @period   = period

      @c = cash_change_summary.filter_by_type(:c) # just make this a member....
      @i = cash_change_summary.filter_by_type(:i)
      @d = cash_change_summary.filter_by_type(:d)
      @f = cash_change_summary.filter_by_type(:f)

      @c.title = "Cash from operations"
      @i.title = "Cash investments in operations"
      @d.title = "Payments to debtholders"
      @f.title = "Payments to stockholders"

      if !(cash_change_summary.is_a? CashChangeSummaryFromDifferences)
        @d.rows << CalculationRow.new(:key => "Investment in Cash and Equivalents",
                                                        :type => :d,
                                                        :vals => [-cash_change_summary.total])
      end
    end

    def -(re_cfs2)
      summary = CashChangeSummaryFromDifferences.new(self, re_cfs2)
      return ReformulatedCashFlowStatement.new(@period, summary)
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
      cs.rows = [ CalculationRow.new(:key => "Cash from Operations (C)",          :vals => [@c.total] ),
                  CalculationRow.new(:key => "Cash Investment in Operations (I)", :vals => [@i.total] ) ]
      return cs
    end

    def financing_flows
      cs = FinModeling::CalculationSummary.new
      cs.title = "Financing Flows"
      cs.rows = [ CalculationRow.new(:key => "Payments to debtholders (d)",  :vals => [@d.total] ),
                  CalculationRow.new(:key => "Payments to stockholders (F)", :vals => [@f.total] ) ]
      return cs
    end

    def ni_over_c(inc_stmt)
      inc_stmt.comprehensive_income.total.to_f / cash_from_operations.total
    end
  
    def self.empty_analysis
      analysis = CalculationSummary.new
  
      analysis.title = ""
      analysis.header_row = CalculationHeader.new(:key => "", :vals =>  ["Unknown..."])
  
      analysis.rows = []
      analysis.rows << CalculationRow.new(:key => "C   ($MM)", :vals => [nil])
      analysis.rows << CalculationRow.new(:key => "I   ($MM)", :vals => [nil])
      analysis.rows << CalculationRow.new(:key => "d   ($MM)", :vals => [nil])
      analysis.rows << CalculationRow.new(:key => "F   ($MM)", :vals => [nil])
      analysis.rows << CalculationRow.new(:key => "FCF ($MM)", :vals => [nil])
      analysis.rows << CalculationRow.new(:key => "NI / C",    :vals => [nil])
 
      return analysis
    end

    def analysis(inc_stmt)
      analysis = CalculationSummary.new
  
      analysis.title = ""
      analysis.header_row = CalculationHeader.new(:key => "", :vals => [@period.value["end_date"].to_s])
  
      analysis.rows = []
      analysis.rows << CalculationRow.new(:key => "C   ($MM)", :vals => [cash_from_operations.total.to_nearest_million])
      analysis.rows << CalculationRow.new(:key => "I   ($MM)", :vals => [cash_investments_in_operations.total.to_nearest_million])
      analysis.rows << CalculationRow.new(:key => "d   ($MM)", :vals => [payments_to_debtholders.total.to_nearest_million])
      analysis.rows << CalculationRow.new(:key => "F   ($MM)", :vals => [payments_to_stockholders.total.to_nearest_million])
      analysis.rows << CalculationRow.new(:key => "FCF ($MM)", :vals => [free_cash_flow.total.to_nearest_million])
      if inc_stmt
        analysis.rows << CalculationRow.new(:key => "NI / C",  :vals => [ni_over_c(inc_stmt)])
      else
        analysis.rows << CalculationRow.new(:key => "NI / C",  :vals => [nil])
      end
 
      return analysis
    end

    ALLOWED_IMBALANCE = 1.0
    def flows_are_balanced?
      (free_cash_flow.total - financing_flows.total) < ALLOWED_IMBALANCE
    end

    def flows_are_plausible?
      return [ payments_to_debtholders,
               payments_to_stockholders,
               cash_from_operations,
               cash_investments_in_operations ].all?{ |x| x.total.abs > 1.0 }
    end

  end
end
