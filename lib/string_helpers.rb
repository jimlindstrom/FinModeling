class String
  def fixed_width_left_justify(width)
    return self[0..(width-1  )]       if self.length == width
    return self[0..(width-1-3)]+"..." if self.length > width
    return self + (" " * (width - self.length))
  end

  def fixed_width_right_justify(width)
    return       self[(-width  )..-1] if self.length == width
    return "..."+self[(-width+3)..-1] if self.length > width
    return (" " * (width - self.length)) + self
  end

  def with_thousands_separators
    self.reverse.scan(/(?:\d*\.)?\d{1,3}-?/).join(',').reverse
  end

  def matches_regexes?(regexes)
    return regexes.inject(false){ |matches, regex| matches or regex =~ self }
  end
end
