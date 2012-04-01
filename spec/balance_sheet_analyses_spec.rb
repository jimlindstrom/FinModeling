# balance_sheets_analyses_spec.rb

require 'spec_helper'

describe FinModeling::BalanceSheetAnalyses do
  before(:all) do
    @summary = FinModeling::CalculationSummary.new
    @summary.title = "Title 123"
    @summary.rows = [ ]
    @summary.rows << FinModeling::CalculationRow.new(:key => "NOA Growth", :type => :oa, :vals => [  4])
    @summary.rows << FinModeling::CalculationRow.new(:key => "Row",        :type => :fa, :vals => [109])
    @summary.rows << FinModeling::CalculationRow.new(:key => "Row",        :type => :oa, :vals => [ 93])
    @summary.rows << FinModeling::CalculationRow.new(:key => "Row",        :type => :fa, :vals => [  1])
  end

  describe ".new" do
    subject { FinModeling::BalanceSheetAnalyses.new(@summary) }

    it { should be_a_kind_of FinModeling::CalculationSummary }
    its(:title)              { should == @summary.title }
    its(:rows)               { should == @summary.rows }
    its(:header_row)         { should == @summary.header_row }
    its(:rows)               { should == @summary.rows }
    its(:num_value_columns)  { should == @summary.num_value_columns }
    its(:key_width)          { should == @summary.key_width }
    its(:val_width)          { should == @summary.val_width }
    its(:max_decimals)       { should == @summary.max_decimals }
    its(:totals_row_enabled) { should be_false }
  end

  describe ".print_extras" do
    subject { FinModeling::BalanceSheetAnalyses.new(@summary) }

    it { should respond_to(:print_extras) }
  end

  describe ".noa_growth_row" do
    subject { FinModeling::BalanceSheetAnalyses.new(@summary).noa_growth_row }

    it { should be_a FinModeling::CalculationRow }
    its(:key) { should == "NOA Growth" }
  end
end
