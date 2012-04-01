RSpec::Matchers.define :be_in do |expected|
  match do |actual|
    expected.include?(actual)
  end

  description { "be one of #{expected}" }
  failure_message_for_should     { |actual| "expected one of #{expected} but got '#{actual}'" }
  failure_message_for_should_not { |actual| "expected other one of #{expected} but got '#{actual}'" }
end

RSpec::Matchers.define :have_the_same_periods_as do |expected|
  match do |actual|
    str1 = actual  .periods.map{|x| x.to_pretty_s}.join(',')
    str2 = expected.periods.map{|x| x.to_pretty_s}.join(',')
    str1 == str2
  end
end

RSpec::Matchers.define :have_a_plausible_total do 
  match do |actual|
    actual.total.abs >= 1.0
  end
 
  description { "have a plausible total" }
  failure_message_for_should     { |actual| "expected that #{actual} would have a total with an absolute value > 1.0" }
  failure_message_for_should_not { |actual| "expected that #{actual} would not have a total with an absolute value > 1.0" }
end

RSpec::Matchers.define :have_the_same_last_total_as do |expected|
  match do |actual|
    period = actual.periods.last
    val1 = actual  .summary(:period=>period).total
    val2 = expected.summary(:period=>period).total
    (val1 - val2).abs <= 0.1
  end

  description { "have the same last reformulated total as #{expected}" }
  failure_message_for_should     { |actual| "expected that #{actual} would have the same last total as #{expected}" }
  failure_message_for_should_not { |actual| "expected that #{actual} would not have the same last total as #{expected}" }
end

RSpec::Matchers.define :have_the_same_last_total do |calc|
  match do |actual|
    a = actual  .send(calc)
    e = expected.send(calc)

    period = a.periods.last
    val1 = a.summary(:period=>period).total
    val2 = e.summary(:period=>period).total
    (val1 - val2).abs <= 0.1
  end
  chain :as do |expected|
    @expected = expected
  end

  description { "have #{calc} with the same last total as #{@expected}" }
  failure_message_for_should     { |actual| "expected that #{actual}'s #{calc} would have the same last total as #{@expected}" }
  failure_message_for_should_not { |actual| "expected that #{actual}'s #{calc} would not have the same last total as #{@expected}" }
end

RSpec::Matchers.define :have_the_same_reformulated_last_total do |calc|
  match do |actual|
    period = actual.periods.last
    val1 = actual  .reformulated(period).send(calc).total
    val2 = expected.reformulated(period).send(calc).total
    (val1 - val2).abs <= 0.1
  end
  chain :as do |expected|
    @expected = expected
  end

  description { "have the same last reformulated total as #{@expected}" }
  failure_message_for_should     { |actual| "expected that #{actual} would have the same last reformulated total as #{@expected}" }
  failure_message_for_should_not { |actual| "expected that #{actual} would not have the same last reformulated total as #{@expected}" }
end

