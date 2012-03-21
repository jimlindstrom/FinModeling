# company_filing_calculation_spec.rb

require 'spec_helper'

describe FinModeling::MultiColumnCalculationSummary do
  before(:all) do
    @summary = FinModeling::MultiColumnCalculationSummary.new
    @summary.title = "CS 1"
    @summary.rows = [ FinModeling::MultiColumnCalculationSummaryRow.new(:key => "Row", :vals => [nil, 0, nil, -101, 2.4]) ]
  end

  describe "valid_vals" do
    subject { @summary.rows.first.valid_vals }
    it "should return all non-nil values" do
      subject.should == @summary.rows[0].vals.select{ |x| !x.nil? }
    end
  end

  describe "+" do
    before(:all) do
      @cs1 = FinModeling::CalculationSummary.new
      @cs1.title = "CS 1"
      @cs1.rows = [ FinModeling::CalculationSummaryRow.new(:key => "First  Row", :val => 1),
                    FinModeling::CalculationSummaryRow.new(:key => "Second Row", :val => 2) ]
       
      @cs2 = FinModeling::CalculationSummary.new
      @cs2.title = "CS 2"
      @cs2.rows = [ FinModeling::CalculationSummaryRow.new(:key => "First  Row", :val => 11),
                    FinModeling::CalculationSummaryRow.new(:key => "Second Row", :val => 22) ]
     
      @cs3 = FinModeling::CalculationSummary.new
      @cs3.title = "CS 3"
      @cs3.rows = [ FinModeling::CalculationSummaryRow.new(:key => "First  Row", :val => 111),
                    FinModeling::CalculationSummaryRow.new(:key => "Second Row", :val => 222) ]

      @mccs12 = @cs1 + @cs2
      @mccs123 = @mccs12 + @cs3
    end

    subject { @mccs123 }

    it { should be_an_instance_of FinModeling::MultiColumnCalculationSummary }

    its(:title) { should == @mccs12.title }

    it "should set the row labels to the first summary's row labels" do
      @mccs123.rows.map{ |row| row.key }.should == @mccs12.rows.map{ |row| row.key }
    end

    it "should merge the values of summary into an array of values in the result" do
      0.upto(@mccs123.rows.length-1).each do |row_idx|
        @mccs123.rows[row_idx].vals.should == ( @mccs12.rows[row_idx].vals + [ @cs3.rows[row_idx].val ] )
      end
    end
  end
end
