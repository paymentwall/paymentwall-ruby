module Paymentwall
	class Widget < Paymentwall::Base
		
		BASE_URL = 'https://api.paymentwall.com/api'

		def initialize(userId, widgetCode, products = [], extraParams = {})
			@userId = userId
			@widgetCode = widgetCode
			@extraParams = extraParams
			@products = products
		end

		def getDefaultSignatureVersion()
			return self.class::getApiType() != self.class::API_CART ? self.class::DEFAULT_SIGNATURE_VERSION : self.class::SIGNATURE_VERSION_2
		end

		
		def getUrl()
			params = {
				'key' => self.class::getAppKey(),
				'uid' => @userId,
				'widget' => @widgetCode
			}

			productsNumber = @products.count()

			if self.class::getApiType() == self.class::API_GOODS

				if @products.kind_of?(Array)

					if productsNumber == 1
						product = @products[0]
						if product.kind_of?(Paymentwall::Product)

							postTrialProduct = nil
							if product.getTrialProduct().kind_of?(Paymentwall::Product)
 								postTrialProduct = product
 								product = product.getTrialProduct()
							end

							params['amount'] = product.getAmount()
							params['currencyCode'] = product.getCurrencyCode()
							params['ag_name'] = product.getName()
							params['ag_external_id'] = product.getId()
							params['ag_type'] = product.getType()

							if product.getType() == Paymentwall::Product::TYPE_SUBSCRIPTION
								params['ag_period_length'] = product.getPeriodLength()
								params['ag_period_type'] = product.getPeriodType()
								if product.isRecurring()

									params['ag_recurring'] = product.isRecurring() ? 1 : 0

									if postTrialProduct
										params['ag_trial'] = 1;
										params['ag_post_trial_external_id'] = postTrialProduct.getId()
										params['ag_post_trial_period_length'] = postTrialProduct.getPeriodLength()
										params['ag_post_trial_period_type'] = postTrialProduct.getPeriodType()
										params['ag_post_trial_name'] = postTrialProduct.getName()
										params['post_trial_amount'] = postTrialProduct.getAmount()
										params['post_trial_currencyCode'] = postTrialProduct.getCurrencyCode()
									end
								end
							end
						else
							#TODO: self.appendToErrors('Not an instance of Paymentwall::Product')
						end
					else 
						#TODO: self.appendToErrors('Only 1 product is allowed in flexible widget call')
					end

				end

			elsif self.class::getApiType() == self.class::API_CART
				index = 0
				@products.each do |product|
					params['external_ids[' + index.to_s + ']'] = product.getId()

					if product.getAmount() > 0
						params['prices[' + index.to_s + ']'] = product.getAmount()
					end
					if product.getCurrencyCode() != '' && product.getCurrencyCode() != nil
						params['currencies[' + index.to_s + ']'] = product.getCurrencyCode()
					end
					index += 1
				end
			end

			params['sign_version'] = signatureVersion = self.getDefaultSignatureVersion()

			if @extraParams.include?('sign_version')
				signatureVersion = params['sign_version'] = @extraParams['sign_version']
			end

			params = params.merge(@extraParams)

			params['sign'] = self.class.calculateSignature(params, self.class::getSecretKey(), signatureVersion)

			return self.class::BASE_URL + '/' + self.buildController(@widgetCode) + '?' + self.http_build_query(params)
		end

		def getHtmlCode(attributes = {})
			defaultAttributes = {
				'frameborder' => '0',
				'width' => '750',
				'height' => '800'
			}

			attributes = defaultAttributes.merge(attributes)

			attributesQuery = ''
			attributes.each do |attr, value|
				attributesQuery += ' ' + attr.to_s + '="' + value.to_s + '"'
			end

			return '<iframe src="' + self.getUrl() + '" ' + attributesQuery + '></iframe>'
		end

		def self.calculateSignature(params, secret, version)
			require 'digest'
			baseString = ''

			if version == self::SIGNATURE_VERSION_1
				# TODO: throw exception if no uid parameter is present

				baseString += params.include?('uid') ? params['uid'] : ''
				baseString += secret

				return Digest::MD5.hexdigest(baseString)

			else

				keys = params.keys.sort

				keys.each do |name| 
					p = params[name]

					# converting array to hash
					if p.kind_of?(Array)
						p = Hash[p.map.with_index { |key, value| [value, key] }]
					end

					if p.kind_of?(Hash)
						subKeys = p.keys.sort
						subKeys.each do |key|
							value = p[key] 
							baseString += "#{name}[#{key}]=#{value}"
						end
					else
						baseString += "#{name}=#{p}"
					end
				end

				baseString += secret

				if version == self::SIGNATURE_VERSION_3
					return Digest::SHA256.hexdigest(baseString)
				else 
					return Digest::MD5.hexdigest(baseString)
				end

			end
		end
		
		protected

		def buildController(widget, flexibleCall = false)
			if self.class::getApiType() == self.class::API_VC
				if !/^w|s|mw/.match(widget)
					return self.class::CONTROLLER_PAYMENT_VIRTUAL_CURRENCY
				end
			elsif self.class::getApiType() == self.class::API_GOODS
				if !flexibleCall
					if !/^w|s|mw/.match(widget)
						return self.class::CONTROLLER_PAYMENT_DIGITAL_GOODS
					end
				else
					return self.class::CONTROLLER_PAYMENT_DIGITAL_GOODS
				end
			else
				return self.class::CONTROLLER_PAYMENT_CART
			end

			return ''
		end

		def http_build_query(params)
			result = [];
			params.each do |key, value|
				result.push(key + '=' + self.url_encode(value))
			end
			return result.join('&')
		end

		def url_encode(value)
			ERB::Util.url_encode(value.to_s)
		end
	end
end
