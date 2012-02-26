module Xbrlware

  class Item
    def pretty_name
      self.name.gsub(/([a-z])([A-Z])/, '\1 \2')
    end

    def value_with_correct_sign(type_to_flip)
      if self.def.nil?
        raise RuntimeError.new("item doesn't have xbrl:balance definition, which should be either 'credit' or 'debit'")
      end

      return (self.def["xbrli:balance"] == type_to_flip) ? -self.value.to_f : self.value.to_f
    end
  end

end
