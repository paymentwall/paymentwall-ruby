Given(/^Pingback GET parameters "([^"]*)"$/) do |arg1|

  @queryData = URI::QueryParams.parse(arg1)
 
end

Given(/^Pingback IP address "([^"]*)"$/) do |arg1|
  @ipAddress = arg1
end

When(/^Pingback is constructed$/) do
  @pingback = Paymentwall::Pingback.new(@queryData, @ipAddress)
end

Then(/^Pingback validation result should be "([^"]*)"$/) do |arg1|
  assert_equal(arg1,@pingback.validate().to_s)
end

Then(/^Pingback method "([^"]*)" should return "([^"]*)"$/) do |arg1, arg2|
  assert_equal(arg2.to_s,@pingback.method(arg1).call.to_s)
end