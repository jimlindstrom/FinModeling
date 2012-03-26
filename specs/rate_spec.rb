# rate_spec.rb

require 'spec_helper'

describe FinModeling::Rate  do
  describe ".annualize" do
    let(:val) { 0.2 }
    context "when annualizing from a quarter to a year" do
      subject { FinModeling::Rate.new(val).annualize(from_days=365.0/4.0, to_days=365.0) }
      it { should be_a_kind_of Float }
      it { should be_within(0.0001).of( (val+1.0)**(4.00) - 1.0 ) }
    end
    context "when annualizing from a year to a quarter" do
      subject { FinModeling::Rate.new(val).annualize(from_days=365.0, to_days=365.0/4.0) }
      it { should be_a_kind_of Float }
      it { should be_within(0.0001).of( (val+1.0)**(0.25) - 1.0 ) }
    end
  end

  describe ".yearly_to_quarterly" do
    let(:val) { 0.2 }
    subject { FinModeling::Rate.new(val).yearly_to_quarterly }
    it { should be_a_kind_of Float }
    it { should be_within(0.0001).of( FinModeling::Rate.new(val).annualize(from_days=365.0, to_days=365.0/4.0) ) }
  end

  describe ".quarterly_to_yearly" do
    let(:val) { 0.2 }
    subject { FinModeling::Rate.new(val).quarterly_to_yearly }
    it { should be_a_kind_of Float }
    it { should be_within(0.0001).of( FinModeling::Rate.new(val).annualize(from_days=365.0/4.0, to_days=365.0) ) }
  end
end
