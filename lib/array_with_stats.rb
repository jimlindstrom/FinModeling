module FinModeling

  class ArrayWithStats < Array
    def mean
      return nil if empty?
      self.inject(:+) / self.length
    end

    def variance
      x_sqrd = self.map{ |x| x*x }
      x_sqrd_mean = (ArrayWithStats.new(x_sqrd).mean)
      x_sqrd_mean - (mean**2)
    end

    def linear_regression
      x = Array(0..(self.length-1)).to_scale
      y = self.to_scale
      Statsample::Regression.simple(x,y)
    end
  end

end
