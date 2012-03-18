class Fixnum
  def to_nearest_thousand
    return (self/1000.0).round.to_f
  end
end

class Float
  def to_nearest_thousand
    return (self/1000.0).round.to_f
  end
end
