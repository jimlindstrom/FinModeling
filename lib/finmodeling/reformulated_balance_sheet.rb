# encoding: utf-8

module FinModeling
  class ReformulatedBalanceSheet
    attr_accessor :period

    def initialize(period, assets_summary, liabs_and_equity_summary)
      @period = period
      @oa  = assets_summary.filter_by_type(:oa)
      @fa  = assets_summary.filter_by_type(:fa)
      @ol  = liabs_and_equity_summary.filter_by_type(:ol)
      @fl  = liabs_and_equity_summary.filter_by_type(:fl)
      @cse = liabs_and_equity_summary.filter_by_type(:cse)
      @mi  = liabs_and_equity_summary.filter_by_type(:mi)
    end

    def operating_assets
      @oa
    end

    def financial_assets
      @fa
    end

    def operating_liabilities
      @ol
    end

    def financial_liabilities
      @fl
    end

    def net_operating_assets
      cs = FinModeling::CalculationSummary.new
      cs.title = "Net Operational Assets"
      cs.rows = [ CalculationRow.new( :key => "OA", :vals => [  @oa.total ] ),
                  CalculationRow.new( :key => "OL", :vals => [ -@ol.total ] ) ]
      return cs
    end

    def net_financial_assets
      cs = FinModeling::CalculationSummary.new
      cs.title = "Net Financial Assets"
      cs.rows = [ CalculationRow.new( :key => "FA", :vals => [  @fa.total ] ),
                  CalculationRow.new( :key => "FL", :vals => [ -@fl.total ] ) ]
      return cs
    end

    def minority_interest
      @mi
    end

    def common_shareholders_equity
      cs = FinModeling::CalculationSummary.new
      cs.title = "Common Shareholders' Equity"
      cs.rows = [ CalculationRow.new( :key => "NOA", :vals => [  net_operating_assets.total ] ),
                  CalculationRow.new( :key => "NFA", :vals => [  net_financial_assets.total ] ),
                  CalculationRow.new( :key => "MI",  :vals => [  -@mi.total                 ] ) ]
      return cs
    end

    def composition_ratio
      net_operating_assets.total / net_financial_assets.total
    end

    def change_in_noa(prev)
      net_operating_assets.total - prev.net_operating_assets.total
    end

    def change_in_cse(prev)
      common_shareholders_equity.total - prev.common_shareholders_equity.total
    end

    def noa_growth(prev)
      rate = change_in_noa(prev) / prev.net_operating_assets.total
      return annualize_rate(prev, rate)
    end

    def cse_growth(prev)
      rate = change_in_cse(prev) / prev.common_shareholders_equity.total
      return annualize_rate(prev, rate)
    end
  
    def analysis(prev)
      analysis = CalculationSummary.new
  
      analysis.title = ""
      analysis.header_row = CalculationHeader.new(:key => "", :vals => [@period.to_pretty_s])
  
      analysis.rows = []
      if Config.balance_detail_enabled?
        analysis.rows << CalculationRow.new(:key => "A ($MM)",:vals => [@oa.total.to_nearest_million +
                                                                               @fa.total.to_nearest_million])
        analysis.rows << CalculationRow.new(:key => "L ($MM)",:vals => [@ol.total.to_nearest_million +
                                                                               @fl.total.to_nearest_million])
      end
      analysis.rows << CalculationRow.new(:key => "NOA ($MM)", :vals => [net_operating_assets.total.to_nearest_million])
      if Config.balance_detail_enabled?
        analysis.rows << CalculationRow.new(:key => "OA ($MM)",:vals => [operating_assets.total.to_nearest_million])
        analysis.rows << CalculationRow.new(:key => "OL ($MM)",:vals => [operating_liabilities.total.to_nearest_million])
      end
      analysis.rows << CalculationRow.new(:key => "NFA ($MM)", :vals => [net_financial_assets.total.to_nearest_million])
      if Config.balance_detail_enabled?
        analysis.rows << CalculationRow.new(:key => "FA ($MM)",:vals => [financial_assets.total.to_nearest_million])
        analysis.rows << CalculationRow.new(:key => "FL ($MM)",:vals => [financial_liabilities.total.to_nearest_million])
      end
      analysis.rows << CalculationRow.new(:key => "Minority Interest ($MM)", :vals => [minority_interest.total.to_nearest_million])
      analysis.rows << CalculationRow.new(:key => "CSE ($MM)", :vals => [common_shareholders_equity.total.to_nearest_million])
      analysis.rows << CalculationRow.new(:key => "Composition Ratio", :vals => [composition_ratio] )
      if prev.nil?
        if Config.balance_detail_enabled?
          analysis.rows << CalculationRow.new(:key => "NOA Δ ($MM)", :vals => [nil] )
          analysis.rows << CalculationRow.new(:key => "CSE Δ ($MM)", :vals => [nil] )
        end
        analysis.rows << CalculationRow.new(:key => "NOA Growth", :vals => [nil] )
        analysis.rows << CalculationRow.new(:key => "CSE Growth", :vals => [nil] )
      else
        if Config.balance_detail_enabled?
          analysis.rows << CalculationRow.new(:key => "NOA Δ ($MM)", :vals => [change_in_noa(prev).to_nearest_million] )
          analysis.rows << CalculationRow.new(:key => "CSE Δ ($MM)", :vals => [change_in_cse(prev).to_nearest_million] )
        end
        analysis.rows << CalculationRow.new(:key => "NOA Growth", :vals => [noa_growth(prev)] )
        analysis.rows << CalculationRow.new(:key => "CSE Growth", :vals => [cse_growth(prev)] )
      end
  
      return analysis
    end

    def self.forecast_next(period, policy, last_re_bs, next_re_is)
      noa = next_re_is.operating_revenues.total / Ratio.new(policy.sales_over_noa).yearly_to_quarterly
      cse = last_re_bs.common_shareholders_equity.total + next_re_is.comprehensive_income.total
      nfa = cse - noa # FIXME: this looks suspect. What about minority interests?

      ForecastedReformulatedBalanceSheet.new(period, noa, nfa, cse)
    end

    private

    def annualize_rate(prev, rate)
      from_days = Xbrlware::DateUtil.days_between(prev.period.value, @period.value)
      return Rate.new(rate).annualize(from_days, to_days=365)
    end

    def deannualize_rate(prev, rate)
      to_days = Xbrlware::DateUtil.days_between(prev.period.value,   @period.value)
      return Rate.new(rate).annualize(from_days=365, to_days)
    end
  end

end
