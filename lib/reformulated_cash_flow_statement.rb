module FinModeling
  class ReformulatedCashFlowStatement
    attr_accessor :period

    class FakeCashChangeSummary
      def initialize(re_cfs1, re_cfs2)
        @re_cfs1 = re_cfs1
        @re_cfs2 = re_cfs2
      end
      def filter_by_type(key)
        case key
          when :c
            @cs = FinModeling::CalculationSummary.new
            @cs.title = "Cash from Operations"
            @cs.rows = [ CalculationSummaryRow.new(:key => "First  Row", :val =>  @re_cfs1.cash_from_operations.total ),
                         CalculationSummaryRow.new(:key => "Second Row", :val => -@re_cfs2.cash_from_operations.total ) ]
            return @cs
          when :i
            @cs = FinModeling::CalculationSummary.new
            @cs.title = "Cash Investments in Operations"
            @cs.rows = [ CalculationSummaryRow.new(:key => "First  Row", :val =>  @re_cfs1.cash_investments_in_operations.total ),
                         CalculationSummaryRow.new(:key => "Second Row", :val => -@re_cfs2.cash_investments_in_operations.total ) ]
            return @cs
          when :d
            @cs = FinModeling::CalculationSummary.new
            @cs.title = "Payments to Debtholders"
            @cs.rows = [ CalculationSummaryRow.new(:key => "First  Row", :val =>  @re_cfs1.payments_to_debtholders.total ),
                         CalculationSummaryRow.new(:key => "Second Row", :val => -@re_cfs2.payments_to_debtholders.total ) ]
            return @cs
          when :f
            @cs = FinModeling::CalculationSummary.new
            @cs.title = "Payments to Stockholders"
            @cs.rows = [ CalculationSummaryRow.new(:key => "First  Row", :val =>  @re_cfs1.payments_to_stockholders.total ),
                         CalculationSummaryRow.new(:key => "Second Row", :val => -@re_cfs2.payments_to_stockholders.total ) ]
            return @cs
        end
      end
    end

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

      if cash_change_summary.class != FakeCashChangeSummary
        @d.rows << CalculationSummaryRow.new(:key => "Investment in Cash and Equivalents",
                                             :type => :d,
                                             :val => -cash_change_summary.total)
      end
    end

    def -(re_cfs2)
      summary = FakeCashChangeSummary.new(self, re_cfs2)
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

    def ni_over_c(inc_stmt)
      inc_stmt.comprehensive_income.total.to_f / cash_from_operations.total
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
      analysis.rows << CalculationSummaryRow.new(:key => "NI / C", :val => 0)
 
      return analysis
    end

    def analysis(inc_stmt)
      analysis = CalculationSummary.new
  
      analysis.title = ""
      analysis.header_row = CalculationSummaryHeaderRow.new(:key => "", :val =>  @period.value["end_date"].to_s)
  
      analysis.rows = []
      analysis.rows << CalculationSummaryRow.new(:key => "C   (000's)", :val => cash_from_operations.total.to_nearest_thousand)
      analysis.rows << CalculationSummaryRow.new(:key => "I   (000's)", :val => cash_investments_in_operations.total.to_nearest_thousand)
      analysis.rows << CalculationSummaryRow.new(:key => "d   (000's)", :val => payments_to_debtholders.total.to_nearest_thousand)
      analysis.rows << CalculationSummaryRow.new(:key => "F   (000's)", :val => payments_to_stockholders.total.to_nearest_thousand)
      analysis.rows << CalculationSummaryRow.new(:key => "FCF (000's)", :val => free_cash_flow.total.to_nearest_thousand)
      analysis.rows << CalculationSummaryRow.new(:key => "NI / C",      :val => ni_over_c(inc_stmt))
 
      return analysis
    end

  end
end
