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

  def cap_decimals(num_decimals)
    r = Regexp.new('(.*\.[0-9]{' + num_decimals.to_s + '})[0-9]*')
    self.gsub(r, '\1')
  end

  def matches_regexes?(regexes) # FIXME: rename to matches_any?
    return regexes.inject(false){ |matches, regex| matches or regex =~ self }
  end

  def split_into_lines_shorter_than(max_line_width)
    lines = []
    cur_line = []
  
    split(' ').each do |word|
      if (cur_line + [word]).join(' ').length > max_line_width
        lines << cur_line.join(' ')
        cur_line = []
      end
  
      cur_line << word
    end
  
    lines << cur_line.join(' ') if !cur_line.empty?
    lines
  end
end
