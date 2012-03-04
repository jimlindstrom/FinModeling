# company_filing_calculation_spec.rb

require 'spec_helper'

describe FinModeling::MultiColumnCalculationSummary do
  describe "+" do
    before(:each) do
      @cs1 = FinModeling::CalculationSummary.new
      @cs1.title = "CS 1"
      @cs1.rows = [ { :key => "First  Row", :val => 1 },
                    { :key => "Second Row", :val => 2 } ]
       
      @cs2 = FinModeling::CalculationSummary.new
      @cs2.title = "CS 2"
      @cs2.rows = [ { :key => "First  Row", :val => 11 },
                    { :key => "Second Row", :val => 22 } ]
     
      @cs3 = FinModeling::CalculationSummary.new
      @cs3.title = "CS 3"
      @cs3.rows = [ { :key => "First  Row", :val => 111 },
                    { :key => "Second Row", :val => 222 } ]

      @mccs12 = @cs1 + @cs2
    end
    it "should return a MultiColumnCalculationSummary" do
      (@mccs12 + @cs3).should be_an_instance_of FinModeling::MultiColumnCalculationSummary
    end
    it "should set the title to the MCCS's title" do
      (@mccs12 + @cs3).title.should == @mccs12.title
    end
    it "should set the row labels to the first summary's row labels" do
      mccs123 = (@mccs12 + @cs3)
      mccs123.rows.map{ |row| row[:key] }.should == @mccs12.rows.map{ |row| row[:key] }
    end
    it "should merge the values of summary into an array of values in the result" do
      mccs123 = (@mccs12 + @cs3)
      0.upto(1).each do |row_idx|
        mccs123.rows[row_idx][:vals].should == ( @mccs12.rows[row_idx][:vals] + [ @cs3.rows[row_idx][:val] ] )
      end
    end
  end
end
