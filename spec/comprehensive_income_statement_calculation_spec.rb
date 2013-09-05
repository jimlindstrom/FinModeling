require 'spec_helper'

describe FinModeling::ComprehensiveIncomeStatementCalculation  do
  pending "not yet working..."
#  before(:all) do
#    xray_2012_q2_rpt = "http://www.sec.gov/Archives/edgar/data/1288776/000119312511282235/0001193125-11-282235-index.htm"
#    filing_q2 = FinModeling::AnnualReportFiling.download xray_2012_q2_rpt
#    @prev_ci_stmt = filing_q2.comprehensive_income_statement
#
#    xray_2012_q3_rpt = "http://www.sec.gov/Archives/edgar/data/818479/000081847912000023/0000818479-12-000023-index.htm"
#    filing = FinModeling::AnnualReportFiling.download xray_2012_q3_rpt
#    @ci_stmt = filing.comprehensive_income_statement
#    @period = @ci_stmt.periods.last
#  end
#
#  describe ".comprehensive_income_calculation" do
#    subject { @ci_stmt.comprehensive_income_calculation }
#    it { should be_a FinModeling::ComprehensiveIncomeCalculation }
#    its(:label) { should match /comprehensive.*income/i }
#  end
#
#  describe ".is_valid?" do
#    subject { @ci_stmt.is_valid? }
#    it { should == (@ci_stmt.comprehensive_income_calculation.has_net_income_item? || @ci_stmt.comprehensive_income_calculation.has_revenue_item?) }
#  end
#
#  describe ".reformulated" do
#    subject { @ci_stmt.reformulated(@period, ci_calc=nil) } 
#    it { should be_a FinModeling::ReformulatedIncomeStatement }
#  end
#
#  describe ".latest_quarterly_reformulated" do
#    context "has invalid total operating revenues or invalid cost of revenue" do
#      subject{ @ci_stmt.latest_quarterly_reformulated(@ci_stmt, @prev_ci_stmt, @prev_ci_calc) }
#      it { should be_nil }
#    end
#    context "has valid total operating revenues and valid cost of revenue" do
#      pending "need example..."
#      #it { should be_a FinModeling::ReformulatedIncomeStatement }
#    end
#  end
#
#  describe ".write_constructor" do
#    before(:all) do
#      file_name = "/tmp/finmodeling-ci-stmt.rb"
#      item_name = "@ci_stmt"
#      file = File.open(file_name, "w")
#      @ci_stmt.write_constructor(file, item_name)
#      file.close
#
#      eval(File.read(file_name))
#      @loaded_cis = eval(item_name)
#    end
#
#    subject { @loaded_cis }
#    it { should have_the_same_periods_as(@ci_stmt) }
#    #it { should have_the_same_reformulated_last_total(:net_financing_income).as(@ci_stmt) }
#  end
#
end

