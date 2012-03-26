# assets_calculation_spec.rb

require 'spec_helper'

describe FinModeling::CanClassifyRows  do
  before(:all) do
    class AgeItem < String
      def classification_estimates
        case
          when self =~ /^1/ then {:teens=>1.0, :twenties=>0.0, :thirties=>0.0, :fourties=>0.0}
          when self =~ /^2/ then {:teens=>0.0, :twenties=>1.0, :thirties=>0.0, :fourties=>0.0}
          when self =~ /^3/ then {:teens=>0.0, :twenties=>0.0, :thirties=>1.0, :fourties=>0.0}
          when self =~ /^4/ then {:teens=>0.0, :twenties=>0.0, :thirties=>0.0, :fourties=>1.0}
          else                   {:teens=>0.0, :twenties=>0.0, :thirties=>0.0, :fourties=>0.0}
        end
      end
    end
  
    class AgeList
      attr_accessor :calculation

      include FinModeling::CanClassifyRows
  
      ALL_STATES  =                [ :teens, :twenties, :thirties, :fourties ]
      NEXT_STATES = { nil       => [ :teens, :twenties, :thirties, :fourties ],
                      :teens    => [ :teens, :twenties, :thirties, :fourties ],
                      :twenties => [         :twenties, :thirties, :fourties ],
                      :thirties => [                    :thirties, :fourties ],
                      :fourties => [                               :fourties ] }
  
      def classify(args)
        lookahead = [args[:max_lookahead], calculation.rows.length-1].min
        classify_rows(ALL_STATES, NEXT_STATES, calculation.rows, AgeItem, lookahead)
      end
    end
  end

  describe "classify_rows" do
    context "with 1 consecutive error" do
      before(:all) do
        @age_list = AgeList.new
        @age_list.calculation = FinModeling::CalculationSummary.new
        ages = [21, 41, 30, 35]
        @age_list.calculation.rows = ages.collect { |age| FinModeling::CalculationRow.new(:key => age.to_s, :vals => 0) }
      end
      context "with lookahead of 0" do
        it "should fail to correct errors" do
          expected_rows = [:twenties, :fourties, :fourties, :fourties]
          @age_list.classify(:max_lookahead=>0)
          @age_list.calculation.rows.map{ |row| row.type }.should == expected_rows
        end
      end
      context "with lookahead of 1" do
        it "should correct one error" do
          expected_rows = [:twenties, :twenties, :thirties, :thirties]
          @age_list.classify(:max_lookahead=>1)
          @age_list.calculation.rows.map{ |row| row.type }.should == expected_rows
        end
      end
    end
    context "with 2 consecutive errors" do
      before(:all) do
        @age_list = AgeList.new
        @age_list.calculation = FinModeling::CalculationSummary.new
        ages = [21, 41, 40, 25, 30, 35, 38, 40]
        @age_list.calculation.rows = ages.collect { |age| FinModeling::CalculationRow.new(:key => age.to_s, :vals => 0) }
      end
      context "with lookahead of 2" do
        it "should fail to correct errors" do
          expected_rows = [:twenties, :fourties, :fourties, :fourties, :fourties, :fourties, :fourties, :fourties]
          @age_list.classify(:max_lookahead=>2)
          @age_list.calculation.rows.map{ |row| row.type }.should == expected_rows
        end
      end
      context "with lookahead of 3" do
        it "should correct one error" do
          expected_rows = [:twenties, :twenties, :twenties, :twenties, :thirties, :thirties, :thirties, :fourties]
          @age_list.classify(:max_lookahead=>3)
          @age_list.calculation.rows.map{ |row| row.type }.should == expected_rows
        end
      end
    end

  end
end

