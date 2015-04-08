require 'digest'

module Paymentwall
  class Base

    VERSION = '1.0.0'

    API_VC    = 1
    API_GOODS = 2
    API_CART  = 3

    CONTROLLER_PAYMENT_VIRTUAL_CURRENCY = 'ps'
    CONTROLLER_PAYMENT_DIGITAL_GOODS    = 'subscription'
    CONTROLLER_PAYMENT_CART             = 'cart'

    DEFAULT_SIGNATURE_VERSION = 3
    SIGNATURE_VERSION_1       = 1
    SIGNATURE_VERSION_2       = 2
    SIGNATURE_VERSION_3       = 3

    @@api_type = nil
    @@app_key = nil
    @@secret_key = nil

    def self.setApiType(value)
      @@api_type = value
      self
    end

    def self.getApiType
      @@api_type
    end

    def self.setAppKey(value)
      @@app_key = value
      self
    end

    def self.getAppKey
      @@app_key
    end

    def self.setSecretKey(value)
      @@secret_key = value
      self
    end

    def self.getSecretKey
      @@secret_key
    end

    def getErrors
      @errors
    end

    def getErrorSummary
      @errors.join("\n")
    end

    protected

    def self.getDefaultSignatureVersion()
      return getApiType() != API_CART ? DEFAULT_SIGNATURE_VERSION : SIGNATURE_VERSION_2
    end

    def appendToErrors(err)
      @errors ||=[]
      @errors.push(err)
      self
    end
  end
end
