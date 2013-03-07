# encoding: utf-8

module FinModeling
  class ReformulatedBalanceSheet
    attr_accessor :period
    attr_accessor :operating_assets, :financial_assets
    attr_accessor :operating_liabilities, :financial_liabilities
    attr_accessor :minority_interest

    def initialize(period, assets, liabs_and_equity)
      @period = period

      @operating_assets = assets.filter_by_type(:oa)
      @financial_assets = assets.filter_by_type(:fa)
      @operating_liabilities = liabs_and_equity.filter_by_type(:ol)
      @financial_liabilities = liabs_and_equity.filter_by_type(:fl)

      #@cse = liabs_and_equity.filter_by_type(:cse)
      @minority_interest = liabs_and_equity.filter_by_type(:mi)
    end

    def net_operating_assets
      cs = FinModeling::CalculationSummary.new
      cs.title = "Net Operational Assets"
      cs.rows = [ CalculationRow.new( :key => "OA", :vals => [  @operating_assets.total ] ),
                  CalculationRow.new( :key => "OL", :vals => [ -@operating_liabilities.total ] ) ]
      return cs
    end

    def net_financial_assets
      cs = FinModeling::CalculationSummary.new
      cs.title = "Net Financial Assets"
      cs.rows = [ CalculationRow.new( :key => "FA", :vals => [  @financial_assets.total ] ),
                  CalculationRow.new( :key => "FL", :vals => [ -@financial_liabilities.total ] ) ]
      return cs
    end

    def common_shareholders_equity
      cs = FinModeling::CalculationSummary.new
      cs.title = "Common Shareholders' Equity"
      cs.rows = [ CalculationRow.new( :key => "NOA", :vals => [  net_operating_assets.total ] ),
                  CalculationRow.new( :key => "NFA", :vals => [  net_financial_assets.total ] ),
                  CalculationRow.new( :key => "MI",  :vals => [  -@minority_interest.total ] ) ]
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
        analysis.rows << CalculationRow.new(:key => "A ($MM)",:vals => [@operating_assets.total.to_nearest_million +
                                                                        @financial_assets.total.to_nearest_million])
        analysis.rows << CalculationRow.new(:key => "L ($MM)",:vals => [@operating_liabilities.total.to_nearest_million +
                                                                        @financial_liabilities.total.to_nearest_million])
      end
      analysis.rows << CalculationRow.new(:key => "NOA ($MM)", :vals => [net_operating_assets.total.to_nearest_million])
      if Config.balance_detail_enabled?
        analysis.rows << CalculationRow.new(:key => "OA ($MM)",:vals => [@operating_assets.total.to_nearest_million])
        analysis.rows << CalculationRow.new(:key => "OL ($MM)",:vals => [@operating_liabilities.total.to_nearest_million])
      end
      analysis.rows << CalculationRow.new(:key => "NFA ($MM)", :vals => [net_financial_assets.total.to_nearest_million])
      if Config.balance_detail_enabled?
        analysis.rows << CalculationRow.new(:key => "FA ($MM)",:vals => [@financial_assets.total.to_nearest_million])
        analysis.rows << CalculationRow.new(:key => "FL ($MM)",:vals => [@financial_liabilities.total.to_nearest_million])
      end
      analysis.rows << CalculationRow.new(:key => "Minority Interest ($MM)", :vals => [@minority_interest.total.to_nearest_million])
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
