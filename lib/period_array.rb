module FinModeling
  class PeriodArray < Array
    def quarterly
      PeriodArray.new(self.select{ |x| (Xbrlware::DateUtil.months_between(x.value["end_date"], x.value["start_date"]) >=  2) and 
                                       (Xbrlware::DateUtil.months_between(x.value["end_date"], x.value["start_date"]) <=  4) })
    end

    def halfyearly
      PeriodArray.new(self.select{ |x| (Xbrlware::DateUtil.months_between(x.value["end_date"], x.value["start_date"]) >=  5) and 
                                       (Xbrlware::DateUtil.months_between(x.value["end_date"], x.value["start_date"]) <=  7) })
    end

    def threequarterly
      PeriodArray.new(self.select{ |x| (Xbrlware::DateUtil.months_between(x.value["end_date"], x.value["start_date"]) >=  8) and 
                                       (Xbrlware::DateUtil.months_between(x.value["end_date"], x.value["start_date"]) <= 10) })
    end

    def yearly
      PeriodArray.new(self.select{ |x| (Xbrlware::DateUtil.months_between(x.value["end_date"], x.value["start_date"]) >= 11) and 
                                       (Xbrlware::DateUtil.months_between(x.value["end_date"], x.value["start_date"]) <= 13) })
    end
  end
end

