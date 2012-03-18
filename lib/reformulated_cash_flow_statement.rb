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

      @d.rows << CalculationSummaryRow.new(:key => "Investment in Cash and Equivalents",
                                           :type => :d,
                                           :val => -cash_change_summary.total)
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
      cs.rows = [ CalculationSummaryRow.new(:key => "Cash from Operations (C)", :val => @c.total ),
                  CalculationSummaryRow.new(:key => "Cash Investment in Operations (I)", :val => @i.total ) ]
      return cs
    end

    def financing_flows
      cs = FinModeling::CalculationSummary.new
      cs.title = "Financing Flows"
      cs.rows = [ CalculationSummaryRow.new(:key => "Payments to debtholders (d)", :val => @d.total ),
                  CalculationSummaryRow.new(:key => "Payments to stockholders (F)", :val => @f.total ) ]
      return cs
    end
  
    def self.empty_analysis
      analysis = CalculationSummary.new
  
      analysis.title = ""
      analysis.header_row = CalculationSummaryHeaderRow.new(:key => "", :val =>  "Unknown...")
  
      analysis.rows = []
      analysis.rows << CalculationSummaryRow.new(:key => "C (000's)", :val => 0)
      analysis.rows << CalculationSummaryRow.new(:key => "I (000's)", :val => 0)
      analysis.rows << CalculationSummaryRow.new(:key => "d (000's)", :val => 0)
      analysis.rows << CalculationSummaryRow.new(:key => "F (000's)", :val => 0)
      analysis.rows << CalculationSummaryRow.new(:key => "FCF (000's)", :val => 0)
 
      return analysis
    end

    def analysis
      analysis = CalculationSummary.new
  
      analysis.title = ""
      analysis.header_row = CalculationSummaryHeaderRow.new(:key => "", :val =>  @period.value["end_date"].to_s)
  
      analysis.rows = []
      analysis.rows << CalculationSummaryRow.new(:key => "C   (000's)", :val => cash_from_operations.total.to_nearest_thousand)
      analysis.rows << CalculationSummaryRow.new(:key => "I   (000's)", :val => cash_investments_in_operations.total.to_nearest_thousand)
      analysis.rows << CalculationSummaryRow.new(:key => "d   (000's)", :val => payments_to_debtholders.total.to_nearest_thousand)
      analysis.rows << CalculationSummaryRow.new(:key => "F   (000's)", :val => payments_to_stockholders.total.to_nearest_thousand)
      analysis.rows << CalculationSummaryRow.new(:key => "FCF (000's)", :val => free_cash_flow.total.to_nearest_thousand)
 
      return analysis
    end

  end
end
