module Paymentwall
	class Base

		VERSION = '1.0.0'

		API_VC = 1
		API_GOODS = 2
		API_CART = 3

		CONTROLLER_PAYMENT_VIRTUAL_CURRENCY = 'ps'
		CONTROLLER_PAYMENT_DIGITAL_GOODS = 'subscription'
		CONTROLLER_PAYMENT_CART = 'cart'

		DEFAULT_SIGNATURE_VERSION = 3
		SIGNATURE_VERSION_1 = 1
		SIGNATURE_VERSION_2 = 2
		SIGNATURE_VERSION_3 = 3

		@@apiType
		@@appKey
		@@secretKey

		def setApiType(value)
			@@apiType = value
		end

		def getApiType
			@@apiType
		end

		def setAppKey(value)
			@@appKey = value
			self
		end

		def getAppKey
			@@appKey
		end

		def setSecretKey(value)
			@@secretKey = value
			self
		end

		def getSecretKey
			@@secretKey
		end

		def getErrors
			@errors
		end

		def getErrorSummary
			@errors.join("\n")
		end

		protected

		def appendToErrors(err)
			@errors ||=[]
			@errors.push(err)
			self
		end
	end
end