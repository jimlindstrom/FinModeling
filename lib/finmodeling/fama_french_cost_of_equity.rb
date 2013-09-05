module FinModeling
  module FamaFrench
    class MarketHistoricalData
      URL = "http://mba.tuck.dartmouth.edu/pages/faculty/ken.french/ftp/F-F_Research_Data_Factors.zip"
      DATA_PATH = File.join(FinModeling::BASE_PATH, "fama-french/")
      ZIP_FILE  = File.join(DATA_PATH, "F-F_Research_Data_Factors.zip")
      TXT_FILE  = File.join(DATA_PATH, "F-F_Research_Data_Factors.txt")
      CSV_FILE  = File.join(DATA_PATH, "F-F_Research_Data_Factors.csv")
  
      def self.download_data!
        FileUtils.mkdir_p(DATA_PATH) if !File.exists?(DATA_PATH)
        `rm #{ZIP_FILE} #{TXT_FILE} #{CSV_FILE} > /dev/null 2>&1`
        `curl -s -o "#{ZIP_FILE}" "#{URL}"`
        prev_pwd=`pwd`
        ` cd #{DATA_PATH}; 
          unzip -q #{ZIP_FILE}; 
          rm #{ZIP_FILE};
          echo "date,RmRf,SMB,HML,Rf" > #{CSV_FILE};
          grep '^[0-9][0-9][0-9][0-9][0-9][0-9]' #{TXT_FILE} | sed -e 's/  */,/g' | sed -e 's///g' >> #{CSV_FILE};
          rm #{TXT_FILE};
          cd #{prev_pwd} `
      end
  
      def initialize
        MarketHistoricalData.download_data! if !File.exists?(CSV_FILE)
        @rows = CSV.read(CSV_FILE, headers: true)
        raise RuntimeError.new("couldn't read fama-french data. try deleting #{CSV_FILE} and re-running") if @rows.length < 10
      end
  
      def year_and_month_strings
        @rows.map{ |x| x["date"] }
      end
  
      def filter_by_date!(dates_to_keep)
        @rows = @rows.select{ |x| dates_to_keep.include?(x["date"]) }
      end
  
      def rm_rf # mkt return - risk free rate
        @rows.map{ |x| x["RmRf"].to_f / 100.0 }
      end
  
      def smb
        @rows.map{ |x| x["SMB"].to_f / 100.0 }
      end
  
      def hml
        @rows.map{ |x| x["HML"].to_f / 100.0 }
      end
  
      def rf
        @rows.map{ |x| x["Rf"].to_f / 100.0 }
      end
    end
  
    class EquityHistoricalData
      def initialize(company_ticker, num_days)
        daily_quotes = YahooFinance::get_HistoricalQuotes_days(URI::encode(company_ticker), num_days)
        @monthly_quotes = daily_quotes.group_by{ |x| x.date.gsub(/-[0-9][0-9]$/, "") }
                                      .values
                                      .map{ |x| x.sort{ |x,y| x.date <=> y.date }.first }
                                      .sort{ |x,y| x.date <=> y.date }[1..-1]
      end
  
      def year_and_month_strings
        @monthly_quotes.map{ |x| x.date.gsub(/-[0-9][0-9]$/, "").gsub(/-/, "") }
      end
  
      def filter_by_date!(dates_to_keep)
        @monthly_quotes  = @monthly_quotes.select{ |x| dates_to_keep.include?(x.date.gsub(/-[0-9][0-9]$/, "").gsub(/-/, "")) }
      end
  
      def monthly_returns(dividends=[])
         @monthly_quotes.each_cons(2)
                        .map { |pair| 
                               div_entry = dividends.find{ |d| d[:ex_eff_date].strftime("%Y-%m") == pair[1].date.gsub(/-[0-9][0-9]$/, "") }
                               dividend = div_entry ? div_entry[:cash_amt] : 0.0
                               (pair[1].adjClose - pair[0].adjClose + dividend) / pair[0].adjClose 
                             }
      end
  
      def monthly_excess_returns(rf, dividends=[])
        @monthly_quotes.each_cons(2)
                       .map { |pair| 
                              div_entry = dividends.find{ |d| d[:ex_eff_date].strftime("%Y-%m") == pair[1].date.gsub(/-[0-9][0-9]$/, "") }
                              dividend = div_entry ? div_entry[:cash_amt] : 0.0
                              (pair[1].adjClose - pair[0].adjClose + dividend) / pair[0].adjClose 
                            }
                       .zip(rf).map{ |pair| pair[0] - pair[1] }
      end

      def none?; @monthly_quotes.none?; end
      def any?;  @monthly_quotes.any?;  end
      def count; @monthly_quotes.count; end
    end
  
    class EquityCostOfCapital
      def self.from_ticker(company_ticker, num_days=6*365)
        company_historical_data = EquityHistoricalData.new(company_ticker, num_days)
        mkt_historical_data = MarketHistoricalData.new
  
        common_dates = company_historical_data.year_and_month_strings & mkt_historical_data.year_and_month_strings
        mkt_historical_data.filter_by_date!(common_dates)
        company_historical_data.filter_by_date!(common_dates)
  
        monthly_excess_returns = company_historical_data.monthly_excess_returns(mkt_historical_data.rf)
        y = GSL::Vector.alloc(monthly_excess_returns)
        x = GSL::Matrix.alloc([1.0]*y.length,
                              mkt_historical_data.rm_rf.first(y.length),
                              mkt_historical_data.smb  .first(y.length),
                              mkt_historical_data.hml  .first(y.length)).transpose
        c, cov, chisq, status = GSL::MultiFit.linear(x, y)
  
        avg_rm_rf = mkt_historical_data.rm_rf.inject(:+) / mkt_historical_data.rm_rf.length.to_f
        avg_smb   = mkt_historical_data.smb.inject(:+)   / mkt_historical_data.smb.length.to_f
        avg_hml   = mkt_historical_data.hml.inject(:+)   / mkt_historical_data.hml.length.to_f
  
        monthly_cost_of_equity = mkt_historical_data.rf.last + (c[1] * avg_rm_rf) + (c[2] * avg_smb) + (c[3] * avg_hml)
        annual_cost_of_equity  = ((monthly_cost_of_equity+1.0)**12)-1.0
        Rate.new(annual_cost_of_equity)
      end
    end
  end
end
