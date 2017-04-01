require_relative '../../lib/paymentwall.rb'
require 'cgi'
require 'json'
require 'uri/query_params'
require 'minitest'

Given(/^Public key "([^"]*)"$/) do |arg1|
	Paymentwall::Base::setAppKey(arg1) # available in your Paymentwall merchant area
end

Given(/^Private key "([^"]*)"$/) do |arg1|
	Paymentwall::Base::setSecretKey(arg1) # available in your Paymentwall merchant area
end

Given(/^Secret key "([^"]*)"$/) do |arg1|
	Paymentwall::Base::setSecretKey(arg1) # available in your Paymentwall merchant area
end

Given(/^API type "([^"]*)"$/) do |arg1|
	Paymentwall::Base::setApiType(arg1) # available in your Paymentwall merchant area
end
