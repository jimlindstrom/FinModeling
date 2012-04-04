module FinModeling
  class PeriodArray < Array
    def quarterly
      PeriodArray.new(self.select{ |x| x.is_duration? &&
                                       (Xbrlware::DateUtil.days_between(x.value["end_date"], x.value["start_date"]) >=  2*28) && 
                                       (Xbrlware::DateUtil.days_between(x.value["end_date"], x.value["start_date"]) <=  4*31) })
    end

    def halfyearly
      PeriodArray.new(self.select{ |x| x.is_duration? &&
                                       (Xbrlware::DateUtil.days_between(x.value["end_date"], x.value["start_date"]) >=  5*30) && 
                                       (Xbrlware::DateUtil.days_between(x.value["end_date"], x.value["start_date"]) <=  7*31) })
    end

    def threequarterly
      PeriodArray.new(self.select{ |x| x.is_duration? &&
                                       (Xbrlware::DateUtil.days_between(x.value["end_date"], x.value["start_date"]) >=  8*30) && 
                                       (Xbrlware::DateUtil.days_between(x.value["end_date"], x.value["start_date"]) <= 10*31) })
    end

    def yearly
      PeriodArray.new(self.select{ |x| x.is_duration? &&
                                       (Xbrlware::DateUtil.days_between(x.value["end_date"], x.value["start_date"]) >= 11*30) && 
                                       (Xbrlware::DateUtil.days_between(x.value["end_date"], x.value["start_date"]) <= 13*31) })
    end
  end
end

