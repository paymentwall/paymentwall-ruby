module Paymentwall
  class Product

    TYPE_SUBSCRIPTION = 'subscription'
    TYPE_FIXED        = 'fixed'

    PERIOD_TYPE_DAY   = 'day'
    PERIOD_TYPE_WEEK  = 'week'
    PERIOD_TYPE_MONTH = 'month'
    PERIOD_TYPE_YEAR  = 'year'

    def initialize(productId, amount = 0.0, currencyCode = nil, name = nil, productType = self.class::TYPE_FIXED, periodLength = 0, periodType = nil, recurring = false, trialProduct = nil)
      @product_id    = productId
      @amount       = amount.round(2)
      @currency_code = currencyCode
      @name         = name
      @product_type  = productType
      @period_length = periodLength
      @period_type   = periodType
      @recurring    = recurring
      if (productType == Paymentwall::Product::TYPE_SUBSCRIPTION && recurring && recurring != 0)
        @trial_product = trialProduct
      end
    end

    def getId()
      @product_id
    end

    def getAmount()
      @amount
    end

    def getCurrencyCode
      @currency_code
    end

    def getName()
      @name
    end

    def getType()
      @product_type
    end

    def getPeriodType()
      @period_type
    end

    def getPeriodLength()
      @period_length
    end

    def isRecurring()
      @recurring
    end

    def getTrialProduct()
      @trial_product
    end
  end
end
