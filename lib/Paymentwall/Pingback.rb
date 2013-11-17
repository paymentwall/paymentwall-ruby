module Paymentwall
	class Pingback < Paymentwall::Base

		PINGBACK_TYPE_REGULAR = 0
		PINGBACK_TYPE_GOODWILL = 1
		PINGBACK_TYPE_NEGATIVE = 2
		
		def initialize(parameters = {}, ipAddress = '')
			@parameters = parameters
			@ipAddress = ipAddress
		end

		def validate(skipIpWhitelistCheck = false)
			validated = false

			if self.isParametersValid()
				if self.isIpAddressValid() || skipIpWhitelistCheck
					if self.isSignatureValid()
						validated = true
					else 
						self.appendToErrors('Wrong signature')
					end
				else
					self.appendToErrors('IP address is not whitelisted')
				end
			else
				self.appendToErrors('Missing parameters')
			end

			validated
		end

		def isSignatureValid()
			signatureParamsToSign = {}

			if self.class::getApiType() == self.class::API_VC
				signatureParams = Array['uid', 'currency', 'type', 'ref']
			elsif self.class::getApiType() == self.class::API_GOODS
				signatureParams = Array['uid', 'goodsid', 'slength', 'speriod', 'type', 'ref']
			else
				signatureParams = Array['uid', 'goodsid', 'type', 'ref']
				@parameters['sign_version'] = self.class::SIGNATURE_VERSION_2

			end

			if !@parameters.include?('sign_version') || @parameters['sign_version'].to_i == self.class::SIGNATURE_VERSION_1
				signatureParams.each do |field|
					signatureParamsToSign[field] = @parameters.include?(field) ? @parameters[field] : nil
				end
				
				@parameters['sign_version'] = self.class::SIGNATURE_VERSION_1

			else
				signatureParamsToSign = @parameters
			end

			signatureCalculated = self.calculateSignature(signatureParamsToSign, self.class::getSecretKey(), @parameters['sign_version'])
			
			signature = @parameters.include?('sig') ? @parameters['sig'] : nil

			signature == signatureCalculated
		end

		def isIpAddressValid()
			ipsWhitelist = [
				'174.36.92.186',
				'174.36.96.66',
				'174.36.92.187',
				'174.36.92.192',
				'174.37.14.28'
			]

			ipsWhitelist.include? @ipAddress
		end

		def isParametersValid()
			errorsNumber = 0
			requiredParams = []

			if self.class::getApiType() == self.class::API_VC
				requiredParams = ['uid', 'currency', 'type', 'ref', 'sig']
			elsif self.class::getApiType() == self.class::API_GOODS
				requiredParams = ['uid', 'goodsid', 'type', 'ref', 'sig']
			else
				requiredParams = ['uid', 'goodsid', 'type', 'ref', 'sig']
			end

			requiredParams.each do |field|
				if !@parameters.include?(field) # || $parameters[field] === ''
					self.appendToErrors("Parameter #{field} is missing")
					errorsNumber += 1
				end
			end

			errorsNumber == 0
		end

		def getParameter(param)
			if @parameters.include?(param)
				return @parameters[param]
			else 
				return nil
			end
		end

		def getType()
			pingbackTypes = [
				self.class::PINGBACK_TYPE_REGULAR,
				self.class::PINGBACK_TYPE_GOODWILL,
				self.class::PINGBACK_TYPE_NEGATIVE
			]

			if @parameters.include?('type')
				if pingbackTypes.include?(@parameters['type'].to_i)
					return @parameters['type'].to_i
				end
			end

			return nil
		end

		def getUserId
			self.getParameter('uid').to_s
		end

		def getVirtualCurrencyAmount()
			self.getParameter('currency').to_i
		end

		def getProductId()
			self.getParameter('goodsid').to_s
		end

		def getProductPeriodLength()
			self.getParameter('slength').to_i
		end

		def getProductPeriodType()
			self.getParameter('speriod').to_s
		end

		def getProduct()
			Paymentwall::Product.new(
				self.getProductId(),
				0,
				nil,
				nil,
				self.getProductPeriodLength() > 0 ? Paymentwall::Product::TYPE_SUBSCRIPTION : Paymentwall::Product::TYPE_FIXED,
				self.getProductPeriodLength(),
				self.getProductPeriodType()
			)
		end

		def getProducts()
			result = []
			productIds = self.getParameter('goodsid')

			if productIds.kind_of?(Array) && productIds.length > 0
				productIds.each do |id|
					result.push(Paymentwall::Product.new(id))
				end
			end

			return result
		end

		def getReferenceId()
			self.getParameter('ref').to_s
		end

		def getPingbackUniqueId()
			self.getReferenceId().to_s + '_' + self.getType().to_s
		end

		def isDeliverable()
			self.getType() == self.class::PINGBACK_TYPE_REGULAR || self.getType() == self.class::PINGBACK_TYPE_GOODWILL
		end

		def isCancelable()
			self.getType() == self.class::PINGBACK_TYPE_NEGATIVE
		end

		protected

		def calculateSignature(params, secret, version)
			
			params = params.clone
			params.delete('sig')

			sortKeys = (version.to_i == self.class::SIGNATURE_VERSION_2)
			keys = sortKeys ? params.keys.sort : params.keys

			baseString = ''

			keys.each do |name| 
				p = params[name]

				# converting array to hash
				if p.kind_of?(Array)
					p = Hash[p.map.with_index { |key, value| [value, key] }]
				end

				if p.kind_of?(Hash)
					subKeys = sortKeys ? p.keys.sort : p.keys;
					subKeys.each do |key|
						value = p[key] 
						baseString += "#{name}[#{key}]=#{value}"
					end
				else
					baseString += "#{name}=#{p}"
				end
			end

			baseString += secret

			require 'digest'
			if version.to_i == self.class::SIGNATURE_VERSION_3
				return Digest::SHA256.hexdigest(baseString)
			else 
				return Digest::MD5.hexdigest(baseString)
			end
		end
	end
end