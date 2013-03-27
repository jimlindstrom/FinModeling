class Fixnum
  def to_nearest_million(num_decimals=1)
    return (self/1000000.0*(10.0**num_decimals)).round.to_f/(10.0**num_decimals)
  end
  def to_nearest_thousand(num_decimals=1)
    return (self/1000.0*(10.0**num_decimals)).round.to_f/(10.0**num_decimals)
  end
  def to_nearest_dollar(num_decimals=1)
    return ((self*(10.0**num_decimals)).round/(10.0**num_decimals)).to_f
  end
end

class Float
  def to_nearest_million(num_decimals=1)
    return (self/1000000.0*(10.0**num_decimals)).round.to_f/(10.0**num_decimals)
  end
  def to_nearest_thousand(num_decimals=1)
    return (self/1000.0*(10.0**num_decimals)).round.to_f/(10.0**num_decimals)
  end
  def to_nearest_dollar(num_decimals=1)
    return ((self*(10.0**num_decimals)).round/(10.0**num_decimals)).to_f
  end
end
