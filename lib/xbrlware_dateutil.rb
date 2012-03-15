module Xbrlware

  module DateUtil
    def self.days_between(date1=Date.today, date2=Date.today)
      begin
        date1=Date.parse(date1) if date1.is_a?(String)
        date2=Date.parse(date2) if date2.is_a?(String)
        (date1 > date2) ? (recent_date, past_date = date1, date2) : (recent_date, past_date = date2, date1)
        (recent_date - past_date).round
      rescue Exception => e
        0
      end
    end
  end

end
