# shareholder_equity_statement_calculation_spec.rb

require 'spec_helper'

describe FinModeling::ShareholderEquityStatementCalculation  do
  before(:all) do
    FinModeling::Config::disable_caching  # FIXME!!!
    deere_2011_annual_rpt = "http://www.sec.gov/Archives/edgar/data/315189/000110465910063219/0001104659-10-063219-index.htm"
    filing = FinModeling::AnnualReportFiling.download deere_2011_annual_rpt
    @stmt = filing.shareholder_equity_statement
    @period = @stmt.periods.last
  end

  describe ".equity_change_calculation" do
    subject { @stmt.equity_change_calculation }
    it { should be_a FinModeling::EquityChangeCalculation }
    its(:label) { should match /(stock|share)holder.*equity/i }

    #let(:right_side_sum) { @stmt.liabs_and_equity_calculation.leaf_items_sum(:period=>@period) }
    #specify { subject.leaf_items_sum(:period=>@period).should be_within(1.0).of(right_side_sum) }

    it "should have the same last total as the balance sheet''s cse" do
      pending
    end
  end

  describe ".is_valid?" do
    context "always... ?" do
      it "returns true" do
        @stmt.is_valid?.should be_true
      end
    end
  end

  describe ".reformulated" do
    subject { @stmt.reformulated(@period) }
    it { should be_a FinModeling::ReformulatedShareholderEquityStatement }
  end

  describe ".write_constructor" do
    before(:all) do
      file_name = "/tmp/finmodeling-shareholder-equity-stmt.rb"
      item_name = "@stmt"
      file = File.open(file_name, "w")
      @stmt.write_constructor(file, item_name)
      file.close

      eval(File.read(file_name))
      @loaded_stmt = eval(item_name)
    end

    context "after write_constructor()ing it to a file and then eval()ing the results" do
      subject { @loaded_stmt }
      it { should have_the_same_periods_as @stmt }
      #it { should have_the_same_reformulated_last_total(:net_operating_assets).as(@stmt) }
    end
  end

end

