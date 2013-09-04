module FinModeling
  class TimeSeriesEstimator
    attr_reader :a, :b

    def initialize(a, b)
      @a, @b = a, b
    end

    def estimate_on(date)
      x = (date - Date.today)
      a + (b*x)
    end

    def self.from_time_series(dates, ys)
      xs = dates.map{ |date| date - Date.today }

      simple_regression = Statsample::Regression.simple(xs.to_scale, ys.to_scale)
      TimeSeriesEstimator.new(simple_regression.a, simple_regression.b)
    end

    def self.from_const(y)
      TimeSeriesEstimator.new(a=y.first, b=0.0)
    end
  end
end
