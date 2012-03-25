class Fixnum
  def to_nearest_million
    return (self/1000000.0).round.to_f
  end
  def to_nearest_thousand
    return (self/1000.0).round.to_f
  end
end

class Float
  def to_nearest_million
    return (self/1000000.0).round.to_f
  end
  def to_nearest_thousand
    return (self/1000.0).round.to_f
  end
end
