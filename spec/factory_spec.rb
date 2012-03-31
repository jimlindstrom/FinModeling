# factory_spec.rb

require 'spec_helper'

describe FinModeling::Factory  do
  describe "BalanceSheetCalculation" do
    subject { FinModeling::Factory.BalanceSheetCalculation }

    it { should be_an_instance_of FinModeling::BalanceSheetCalculation }
  end

  describe "incomeStatementCalculation" do
    subject { FinModeling::Factory.IncomeStatementCalculation }

    it { should be_an_instance_of FinModeling::IncomeStatementCalculation }
  end
end

