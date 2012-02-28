module FinModeling
  class PeriodArray < Array
    def yearly
      PeriodArray.new(self.select{ |x| (Xbrlware::DateUtil.months_between(x.value["end_date"], x.value["start_date"]) >= 11) and 
                                       (Xbrlware::DateUtil.months_between(x.value["end_date"], x.value["start_date"]) <= 13) })
    end
  end
end

