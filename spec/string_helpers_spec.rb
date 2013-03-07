# string_helpers_spec.rb

require 'spec_helper'

describe String do
  let(:s) { "asdfasdf" }

  describe "matches_regexes?" do
    context "if no regexes are provided" do
      let(:regexes) { [] }
      subject { s.matches_regexes?(regexes) }
      it { should be_false }
    end
    context "if the string does not match any of the regexes" do
      let(:regexes) { [/\d/, /[A-Z]/] }
      subject { s.matches_regexes?(regexes) }
      it { should be_false }
    end
    context "if the string matches one or more of the regexes" do
      let(:regexes) { [/sdf/, /ddd/, /af+/] }
      subject { s.matches_regexes?(regexes) }
      it { should be_true }
    end
  end
end
