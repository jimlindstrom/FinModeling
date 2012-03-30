# income_statement_analyses_spec.rb

require 'spec_helper'

describe FinModeling::IncomeStatementAnalyses do
  before(:all) do
    @summary = FinModeling::CalculationSummary.new
    @summary.title = "Title 123"
    @summary.rows = [ ]
    @summary.rows << FinModeling::CalculationRow.new(:key => "Revenue Growth", :type => :oa, :vals => [  4])
    @summary.rows << FinModeling::CalculationRow.new(:key => "Sales / NOA", :type => :oa, :vals => [  4])
    @summary.rows << FinModeling::CalculationRow.new(:key => "Operating PM", :type => :oa, :vals => [  4])
    @summary.rows << FinModeling::CalculationRow.new(:key => "FI / NFA", :type => :oa, :vals => [  4])
    @summary.rows << FinModeling::CalculationRow.new(:key => "Row", :type => :fa, :vals => [109])
    @summary.rows << FinModeling::CalculationRow.new(:key => "Row", :type => :oa, :vals => [ 93])
    @summary.rows << FinModeling::CalculationRow.new(:key => "Row", :type => :fa, :vals => [  1])
  end

  describe ".new" do
    subject { FinModeling::IncomeStatementAnalyses.new(@summary) }

    it { should be_a_kind_of FinModeling::CalculationSummary }
    its(:title) { should == @summary.title }
    its(:rows) { should == @summary.rows }
    its(:header_row) { should == @summary.header_row }
    its(:rows) { should == @summary.rows }
    its(:num_value_columns) { should == @summary.num_value_columns }
    its(:key_width) { should == @summary.key_width }
    its(:val_width) { should == @summary.val_width }
    its(:max_decimals) { should == @summary.max_decimals }
    its(:totals_row_enabled) { should be_false }
  end

  describe ".print_extras" do
    subject { FinModeling::IncomeStatementAnalyses.new(@summary) }

    it { should respond_to(:print_extras) }
  end

  describe ".revenue_growth_row" do
    subject { FinModeling::IncomeStatementAnalyses.new(@summary).revenue_growth_row }
    it { should be_a FinModeling::CalculationRow }
    its(:key) { should == "Revenue Growth" }
  end

  describe ".operating_pm_row" do
    subject { FinModeling::IncomeStatementAnalyses.new(@summary).operating_pm_row }
    it { should be_a FinModeling::CalculationRow }
    its(:key) { should == "Operating PM" }
  end

  describe ".sales_over_noa_row" do
    subject { FinModeling::IncomeStatementAnalyses.new(@summary).sales_over_noa_row }
    it { should be_a FinModeling::CalculationRow }
    its(:key) { should == "Sales / NOA" }
  end

  describe ".fi_over_nfa_row" do
    subject { FinModeling::IncomeStatementAnalyses.new(@summary).fi_over_nfa_row }
    it { should be_a FinModeling::CalculationRow }
    its(:key) { should == "FI / NFA" }
  end
end
