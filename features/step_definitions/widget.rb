Given(/^Widget signature version "([^"]*)"$/) do |arg1|
  @widgetSignatureVersion = arg1
end

Given(/^Product name "([^"]*)"$/) do |arg1|
  @productName = arg1
end

When(/^Widget is constructed$/) do

  widgetCode = @code.to_s.length > 0 ? @widgetCode : "p1"

  @widget = Paymentwall::Widget.new(
	'user40012',
	widgetCode,
	[
		Paymentwall::Product.new(
			'product301',
			9.99,
			'USD',
			@productName,
			Paymentwall::Product::TYPE_FIXED
		)
    ],
	{'lang' => @languageCode}
  )

end

When(/^Widget HTML content is loaded$/) do
  require 'hpricot'
  require 'open-uri'
  @doc = Hpricot(open(@widget.getUrl()))
end

Then(/^Widget HTML content should not contain "([^"]*)"$/) do |arg1|
  result = (@doc).inner_html.include? arg1
  assert("false",result)
end

Then(/^Widget HTML content should contain "([^"]*)"$/) do |arg1|
  result = (@doc).inner_html.include? arg1
  assert("true",result)
end

Given(/^Widget code "([^"]*)"$/) do |arg1|
  @code = arg1
end

Given(/^Language code "([^"]*)"$/) do |arg1|
  @languageCode = arg1
end

Then(/^Widget URL should contain "([^"]*)"$/) do |arg1|
  result = @widget.getUrl().to_s.include? arg1
  assert("true",result)
end