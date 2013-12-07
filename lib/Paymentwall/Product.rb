module Paymentwall
	class Product

		TYPE_SUBSCRIPTION = 'subscription'
		TYPE_FIXED = 'fixed'

		PERIOD_TYPE_DAY = 'day'
		PERIOD_TYPE_WEEK = 'week'
		PERIOD_TYPE_MONTH = 'month'
		PERIOD_TYPE_YEAR = 'year'

		def initialize(productId, amount = 0.0, currencyCode = nil, name = nil, productType = self.class::TYPE_FIXED, periodLength = 0, periodType = nil, recurring = false, trialProduct = nil)
			@productId = productId
			@amount = amount.round(2)
			@currencyCode = currencyCode
			@name = name
			@productType = productType
			@periodLength = periodLength
			@periodType = periodType
			@reccuring = recurring
			if (productType == Paymentwall::Product::TYPE_SUBSCRIPTION && recurring && recurring != 0) 
				@trialProduct = trialProduct
			end
		end

		def getId()
			@productId
		end

		def getAmount()
			@amount
		end
	 
		def getCurrencyCode
			@currencyCode
		end

		def getName()
			@name
		end

		def getType()
			@productType
		end

		def getPeriodType()
			@periodType
		end

		def getPeriodLength()
			@periodLength
		end

		def isRecurring()
			@reccuring
		end

		def getTrialProduct()
			@trialProduct
		end
	end
end