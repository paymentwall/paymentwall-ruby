# About Paymentwall

[Paymentwall](http://paymentwall.com/?source=gh) is the leading digital payments platform for globally monetizing digital goods and services. Paymentwall assists game publishers, dating sites, rewards sites, SaaS companies and many other verticals to monetize their digital content and services. 
Merchants can plugin Paymentwall's API to accept payments from over 100 different methods including credit cards, debit cards, bank transfers, SMS/Mobile payments, prepaid cards, eWallets, landline payments and others. 

To sign up for a Paymentwall Merchant Account, [click here](http://paymentwall.com/signup/merchant?source=gh).

# Paymentwall Ruby Library

This library allows developers to use [Paymentwall APIs](http://paymentwall.com/en/documentation/API-Documentation/722?source=gh) (Virtual Currency, Digital Goods featuring recurring billing, and Virtual Cart).

To use Paymentwall, all you need to do is to sign up for a Paymentwall Merchant Account so you can setup an Application designed for your site.
To open your merchant account and set up an application, you can [sign up here](http://paymentwall.com/signup/merchant?source=gh).

# Installation

```
gem install paymentwall
```

Alternatively, you can download the [ZIP archive](https://github.com/paymentwall/paymentwall-ruby/archive/master.zip), unzip it and place into your project.

Alternatively, you can run:

```
git clone git://github.com/paymentwall/paymentwall-ruby.git
```

Then use a code sample below.

# Code Samples

## Digital Goods API

### Initializing Paymentwall

```rb
require 'paymentwall' # alternatively, require_relative '/path/to/paymentwall-ruby/lib/paymentwall.rb'
Paymentwall::Base::setApiType(Paymentwall::Base::API_GOODS)
Paymentwall::Base::setAppKey('YOUR_APPLICATION_KEY') # available in your Paymentwall merchant area
Paymentwall::Base::setSecretKey('YOUR_SECRET_KEY') # available in your Paymentwall merchant area
```

### Widget Call

[Web API details](http://www.paymentwall.com/en/documentation/Digital-Goods-API/710#paymentwall_widget_call_flexible_widget_call)

The widget is a payment page hosted by Paymentwall that embeds the entire payment flow: selecting the payment method, completing the billing details, and providing customer support via the Help section. You can redirect the users to this page or embed it via iframe. Below is an example that renders an iframe with Paymentwall Widget.

```rb
widget = Paymentwall::Widget.new(
  'user40012',   # id of the end-user who's making the payment
  'fp',        # widget code, e.g. p1; can be picked inside of your merchant account
  [              # product details for Flexible Widget Call. To let users select the product on Paymentwall's end, leave this array empty
    Paymentwall::Product.new(
      'product301',                            # id of the product in your system
      9.99,                                    # price
      'USD',                                   # currency code
      'Gold Membership',                       # product name
      Paymentwall::Product::TYPE_SUBSCRIPTION, # this is a time-based product
      1,                                       # duration is 1
      Paymentwall::Product::PERIOD_TYPE_MONTH, #               month
      true                                     # recurring
    )
  ],
  {'email' => 'user@hostname.com'}                 # additional parameters
)
puts widget.getHtmlCode()
```

### Pingback Processing

The Pingback is a webhook notifying about a payment being made. Pingbacks are sent via HTTP/HTTPS to your servers. To process pingbacks use the following code:

```rb
pingback = Paymentwall::Pingback.new(request_get_params, request_ip_address)
if pingback.validate()
  productId = pingback.getProduct().getId()
  if pingback.isDeliverable()
    # deliver the product
  elsif pingback.isCancelable()
    # withdraw the product
  end 
  puts 'OK' # Paymentwall expects response to be OK, otherwise the pingback will be resent
else
  puts pingback.getErrorSummary()
end
```

## Virtual Currency API

### Initializing Paymentwall

```rb
require_relative '/path/to/paymentwall-ruby/lib/paymentwall.rb'
Paymentwall::Base::setApiType(Paymentwall::Base::API_VC)
Paymentwall::Base::setAppKey('YOUR_APPLICATION_KEY') # available in your Paymentwall merchant area
Paymentwall::Base::setSecretKey('YOUR_SECRET_KEY') # available in your Paymentwall merchant area
```

### Widget Call

```rb
widget = Paymentwall::Widget.new(
  'user40012', # id of the end-user who's making the payment
  'p1_1',      # widget code, e.g. p1; can be picked inside of your merchant account
  [],          # array of products - leave blank for Virtual Currency API
  {'email' => 'user@hostname.com'} # additional parameters
)
puts widget.getHtmlCode()
```

### Pingback Processing

```rb
pingback = Paymentwall::Pingback.new(request_get_params, request_ip_address)
if pingback.validate()
  virtualCurrency = pingback.getVirtualCurrencyAmount()
  if pingback.isDeliverable()
    # deliver the virtual currency
  elsif pingback.isCancelable()
    # withdraw the virual currency
  end 
  puts 'OK' # Paymentwall expects response to be OK, otherwise the pingback will be resent
else
  puts pingback.getErrorSummary()
end
```

## Cart API

### Initializing Paymentwall

```rb
require_relative '/path/to/paymentwall-ruby/lib/paymentwall.rb'
Paymentwall::Base::setApiType(Paymentwall::Base::API_CART)
Paymentwall::Base::setAppKey('YOUR_APPLICATION_KEY') # available in your Paymentwall merchant area
Paymentwall::Base::setSecretKey('YOUR_SECRET_KEY') # available in your Paymentwall merchant area
```

### Widget Call

```rb
widget = Paymentwall::Widget.new(
  'user40012', # id of the end-user who's making the payment
  'p1_1',      # widget code, e.g. p1; can be picked inside of your merchant account,
  [
    Paymentwall::Product.new('product301', 3.33, 'EUR'), # first product in cart
    Paymentwall::Product.new('product607', 7.77, 'EUR')  # second product in cart
  ],
  {'email' => 'user@hostname.com'} # additional params
)
puts widget.getHtmlCode()
```

### Pingback Processing

```rb
pingback = Paymentwall::Pingback.new(request_get_params, request_ip_address)
if pingback.validate()
  products = pingback.getProducts()
  if pingback.isDeliverable()
    # deliver the products
  elsif pingback.isCancelable()
    # withdraw the products
  end 
  puts 'OK' # Paymentwall expects response to be OK, otherwise the pingback will be resent
else
  puts pingback.getErrorSummary()
end
```
# Testing this gem

To run this gem's test suite locally, follow the steps below.
 
```
# Clone the repository
git clone git@github.com:paymentwall/paymentwall-ruby.git
 
# Install dependencies with Bundler
cd paymentwall-ruby
bundle install
 
# Run tests
rake
```

