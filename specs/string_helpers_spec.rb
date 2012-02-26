# string_helpers_spec.rb

require 'spec_helper'

describe String do
  describe "matches_regexes?" do
    it "returns false if no regexes are provided" do
      s = "asdfasdf"
      regexes = []
      s.matches_regexes?(regexes).should be_false
    end
    it "returns false if the string does not match any of the regexes" do
      s = "asdfasdf"
      regexes = [/\d/, /[A-Z]/]
      s.matches_regexes?(regexes).should be_false
    end
    it "returns true if the string matches one or more of the regexes" do
      s = "asdfasdf"
      regexes = [/sdf/, /ddd/, /af+/]
      s.matches_regexes?(regexes).should be_true
    end
  end
end
