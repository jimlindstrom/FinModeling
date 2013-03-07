module FinModeling
  class CashChangeSummaryFromDifferences
    def initialize(re_cfs1, re_cfs2)
      @re_cfs1 = re_cfs1
      @re_cfs2 = re_cfs2
    end
    def filter_by_type(key)
      case key
        when :c
          @cs = FinModeling::CalculationSummary.new
          @cs.title = "Cash from Operations"
          @cs.rows = [ CalculationRow.new(:key => "First  Row", :vals => [ @re_cfs1.cash_from_operations.total] ),
                       CalculationRow.new(:key => "Second Row", :vals => [-@re_cfs2.cash_from_operations.total] ) ]
          return @cs
        when :i
          @cs = FinModeling::CalculationSummary.new
          @cs.title = "Cash Investments in Operations"
          @cs.rows = [ CalculationRow.new(:key => "First  Row", :vals => [ @re_cfs1.cash_investments_in_operations.total] ),
                       CalculationRow.new(:key => "Second Row", :vals => [-@re_cfs2.cash_investments_in_operations.total] ) ]
          return @cs
        when :d
          @cs = FinModeling::CalculationSummary.new
          @cs.title = "Payments to Debtholders"
          @cs.rows = [ CalculationRow.new(:key => "First  Row", :vals => [ @re_cfs1.payments_to_debtholders.total] ),
                       CalculationRow.new(:key => "Second Row", :vals => [-@re_cfs2.payments_to_debtholders.total] ) ]
          return @cs
        when :f
          @cs = FinModeling::CalculationSummary.new
          @cs.title = "Payments to Stockholders"
          @cs.rows = [ CalculationRow.new(:key => "First  Row", :vals => [ @re_cfs1.payments_to_stockholders.total] ),
                       CalculationRow.new(:key => "Second Row", :vals => [-@re_cfs2.payments_to_stockholders.total] ) ]
          return @cs
      end
    end
  end
end
